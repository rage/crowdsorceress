# frozen_string_literal: true

class Exercise < ApplicationRecord
  belongs_to :assignment
  belongs_to :user
  has_one :exercise_type, through: :assignment
  has_many :peer_reviews
  has_many :exercises_tags, dependent: :destroy
  has_many :tags, through: :exercises_tags
  has_many :peer_review_questions, through: :exercise_type

  require 'tmc_langs'
  require 'sandbox_results_handler'
  require 'zip_handler'
  require 'test_generator'

  has_paper_trail ignore: %i[updated_at status error_messages sandbox_results]

  validates :description, presence: true
  # validates :testIO, presence: true # TODO: do we want to validate testIO? what do we want to validate?
  validates :code, presence: true

  serialize :sandbox_results, Hash

  enum status: %i[status_undefined saved testing_template testing_model_solution half_done finished error sandbox_timeout]

  def reset!
    self.error_messages = []
    status_undefined!
    self.sandbox_results = {status: '', message: '', passed: false, model_results_received: false, template_results_received: false}
    self.tags = []
    self.times_sent_to_sandbox = 0

    self.submit_count += 1
  end

  def add_tags(tags)
    tags.each do |tag|
      tag = Tag.find_or_initialize_by(name: tag.strip.delete("\n").gsub(/\s+/, ' ').downcase)
      self.tags << tag
    end
  end

  def create_submission
    check_if_already_submitted

    write_to_main_file
    write_to_test_file

    create_model_and_template
  end

  def check_if_already_submitted
    if !Dir.exist?(submission_target_path.to_s)
      if self.assignment.course.language == 'Java'
        FileUtils.cp_r Rails.root.join('submission_generation', 'SubmissionTemplate').to_s, submission_target_path.to_s
      else
        FileUtils.cp_r Rails.root.join('submission_generation', 'PythonSubmissionTemplate').to_s, submission_target_path.to_s
      end
    else
      FileUtils.remove_dir(submission_target_path.join('model').to_s, true)
      # FileUtils.remove_dir(submission_target_path.join('template').to_s, true)
    end
  end

  def create_model_and_template
    TMCLangs.prepare_solutions(self)
    # TMCLangs.prepare_templates(self)
  end

  def write_to_main_file
    path = submission_target_path.join('src', 'submission.py').to_s

    if self.assignment.course.language == 'Java'
      path = submission_target_path.join('src', 'Submission.java').to_s
    end

    File.open(path, 'w') do |f|
      f.write(code)
    end
  end

  def write_to_test_file
    path = submission_target_path.join('test', 'test_submission.py').to_s

    if self.assignment.course.language == 'Java'
      path = submission_target_path.join('test', 'SubmissionTest.java').to_s
    end

    if assignment.exercise_type.testing_type == 'student_written_tests' || assignment.exercise_type.testing_type == 'whole_test_code_for_set_up_code'
      File.open(path, 'w') do |f|
        f.write(unit_tests.first['test_code'])
      end
    else
      File.open(path, 'w') do |f|
        f.write(TestGenerator.new.generate(self))
      end
    end
  end

  def handle_results(test_output, package_type)
    SandboxResultsHandler.new(self).handle(test_output, package_type)

    if sandbox_results[:model_results_received] # && sandbox_results[:template_results_received]
      sandbox_results[:passed] ? finished! : error!
    else
      half_done!
    end
    send_results_to_frontend
  end

  def send_results_to_frontend
    MessageBroadcasterJob.perform_now(self) if assignment.show_results_to_user
    ZipHandler.new(self).clean_up if finished?
    FileUtils.remove_dir(submission_target_path.to_s) unless in_progress?
  end

  def in_progress?
    %w[saved testing_template testing_model_solution half_done].include?(status)
  end

  def submission_target_path
    Rails.root.join('submission_generation', 'tmp', "Submission_#{id}")
  end

  def peer_review_tags
    PeerReviewsTag.where(peer_review: peer_reviews).group(:tag).count
  end

  def average_grade
    peer_reviews.inject(0.0) {|sum, review| sum + review.average_grade} / peer_reviews.count
  end

  def peer_review_question_averages
    peer_review_questions.includes(:peer_review_question_answers).map do |question|
      grades = []

      question.peer_review_question_answers.each do |answer|
        review = PeerReview.find answer.peer_review_id
        grades.push answer.grade if review.exercise_id == id
      end

      # grades = question.peer_review_question_answers.pluck(:grade)
      [question.question, grades.sum.to_f / grades.count]
    end.to_h
  end
end

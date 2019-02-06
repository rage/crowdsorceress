# frozen_string_literal: true

class ZipHandler
  require 'zip'

  def initialize(exercise)
    @exercise = exercise
  end

  def clean_up
    update_model_and_template
    create_directories_for_zips
    retire_zips
    create_zips
  end

  private

  def update_model_and_template
    model_file = File.open(submission_target_path.join('model', 'src', 'Submission.java').to_s, 'rb:UTF-8')
    model = model_file.read
    template_file = File.open(submission_target_path.join('template', 'src', 'Submission.java').to_s, 'rb:UTF-8')
    template = template_file.read
    model_file.close
    template_file.close

    @exercise.update(model_solution: model, template: template)
  end

  def create_directories_for_zips
    FileUtils.mkdir_p(exercise_target_path.join('oldies').to_s)
  end

  def create_zips
    create_zip(exercise_target_path.join("Template_#{@exercise.id}.#{@exercise.versions.last.id}.zip").to_s, 'template')
    create_zip(exercise_target_path.join("ModelSolution_#{@exercise.id}.#{@exercise.versions.last.id}.zip").to_s, 'model')
  end

  def retire_zips
    template_file = search_zip_file('Template')
    model_file = search_zip_file('ModelSolution')

    unless template_file.nil?
      FileUtils.mv exercise_target_path.join(template_file), exercise_target_path.join('oldies')
    end

    return if model_file.nil?
    FileUtils.mv exercise_target_path.join(model_file), exercise_target_path.join('oldies')
  end

  def search_zip_file(package_type)
    Dir.entries(exercise_target_path).find { |o| o.end_with?('.zip') && o.include?(package_type) }
  end

  def create_zip(zipfile_name, file)
    input_files = ['lib/testrunner/tmc-junit-runner.jar', 'lib/edu-test-utils-0.4.2.jar', 'lib/junit-4.10.jar',
                   'nbproject/build-impl.xml', 'nbproject/genfiles.properties', 'nbproject/project.properties',
                   'nbproject/project.xml', 'src/Submission.java', 'test/SubmissionTest.java', 'build.xml']

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      input_files.each do |name|
        zipfile.add(name, submission_target_path.join(file.to_s, name.to_s).to_s)
      end
    end
  end

  def assignment_target_path
    Rails.root.join('submission_generation', 'packages', "assignment_#{@exercise.assignment.id}")
  end

  def submission_target_path
    Rails.root.join('submission_generation', 'tmp', "Submission_#{@exercise.id}")
  end

  def exercise_target_path
    Rails.root.join('submission_generation', 'packages', "assignment_#{@exercise.assignment.id}", "exercise_#{@exercise.id}")
  end
end

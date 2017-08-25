# frozen_string_literal: true

class Tarballer
  def create_tar_files(exercise)
    if !exercise_modified?(exercise)
      unmodified_error(exercise)
    else
      exercise.create_submission

      `cd #{tmp_submission_target_path(exercise).join('model').to_s} && tar -cpf #{packages_target_path.join("ModelSolutionPackage_#{exercise.id}.tar").to_s} *`
      `cd #{tmp_submission_target_path(exercise).join('template').to_s} && tar -cpf #{packages_target_path.join("TemplatePackage_#{exercise.id}.tar").to_s} *`
    end
  end

  private

  def exercise_modified?(exercise)
    if Dir.exist?(assignment_target_path(exercise)) && Dir.exist?(assignment_target_path(exercise).join("exercise_#{exercise.id}"))
      if directory_includes_file(exercise, 'ModelSolution') || directory_includes_file(exercise, 'Template')
        return false
      end
    end
    true
  end

  def unmodified_error(exercise)
    exercise.error_messages.push('Tapahtui virhe: Muokkaamaton tehtävä lähetettiin uudelleen')
    exercise.error!
    MessageBroadcasterJob.perform_now(exercise)
  end

  def directory_includes_file(exercise, package_type)
    Dir.entries(assignment_target_path(exercise).join("exercise_#{exercise.id}")).include?("#{package_type}_#{exercise.id}.#{exercise.versions.last.id}.zip")
  end

  def assignment_target_path(exercise)
    Rails.root.join('submission_generation', 'packages', "assignment_#{exercise.assignment.id}")
  end

  def tmp_submission_target_path(exercise)
    Rails.root.join('submission_generation', 'tmp', "Submission_#{exercise.id}")
  end

  def packages_target_path
    Rails.root.join('submission_generation', 'packages')
  end
end

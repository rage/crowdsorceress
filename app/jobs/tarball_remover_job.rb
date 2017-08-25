# frozen_string_literal: true

class TarballRemoverJob < ApplicationJob
  queue_as :default

  def perform(package_type, exercise)
    if package_type == 'TEMPLATE'
      package_name = "TemplatePackage_#{exercise.id}.tar"
    elsif package_type == 'MODEL'
      package_name = "ModelSolutionPackage_#{exercise.id}.tar"
    end
    File.open(packages_target_path.join(package_name).to_s, 'r') do |tar_file|
      `rm #{tar_file.path}`
    end
  end

  private

  def packages_target_path
    Rails.root.join('submission_generation', 'packages')
  end
end

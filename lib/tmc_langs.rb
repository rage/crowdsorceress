# frozen_string_literal: true

class TMCLangs
  def self.langs_path
    filename = Dir.entries(tmc_langs_cli_target_path).find { |o| o.end_with?('.jar') && o.start_with?('tmc-langs') && !o.include?('sources') }
    tmc_langs_cli_target_path.join(filename)
  end

  def self.prepare_solutions
    `java -jar #{langs_path.to_s} prepare-solutions --exercisePath ./submission_generation/Submission/ --outputPath ./langs-tmp/model`
  end

  def self.prepare_stubs
    `java -jar #{langs_path.to_s} prepare-stubs --exercisePath ./submission_generation/Submission/ --outputPath ./langs-tmp/stub`
  end

  private_class_method

  def self.tmc_langs_cli_target_path
    Rails.root.join('ext', 'tmc-langs', 'tmc-langs-cli', 'target')
  end
end

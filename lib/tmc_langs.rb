# frozen_string_literal: true

class TMCLangs
  def self.langs_path
    filename = Dir.entries(tmc_langs_cli_target_path).select { |o| o.end_with?('.jar') && o.start_with?('tmc-langs') }.first
    tmc_langs_cli_target_path.join(filename)
  end

  def self.prepare_solutions
    `java -jar #{langs_path.to_s} prepare-solutions --exercisePath ./Submission/ --outputPath ./langs-tmp/model`
  end

  def self.prepare_stubs
    `java -jar #{langs_path.to_s} prepare-stubs --exercisePath ./Submission/ --outputPath ./langs-tmp/stub`
  end

  private

  def self.tmc_langs_cli_target_path
    Rails.root.join('ext', 'tmc-langs', 'tmc-langs-cli', 'target')
  end
end

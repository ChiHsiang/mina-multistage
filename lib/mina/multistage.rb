
def _default_stage
  fetch(:default_stage, 'staging')
end

def _stages_dir
  fetch(:stages_dir, 'config/deploy')
end

def _all_stages_empty?
  !fetch(:stages, nil)
end

def _file_for_stage(stage_name)
  File.join(_stages_dir, "#{stage_name}.rb")
end

def _stage_file_exists?(stage_name)
  File.exists?(_file_for_stage(stage_name))
end

def _get_all_stages
  Dir["#{_stages_dir}/*.rb"].reduce([]) { |all_stages, file| all_stages << File.basename(file, '.rb') }
end

def _argument_included_in_stages?(arg)
  stages.include?(arg)
end

set :stages, _get_all_stages if _all_stages_empty?

stages.each do |name|
  desc "Set the target stage to '#{name}'."
  task(name) do
    set :stage, name
    file = "#{_stages_dir}/#{stage}.rb"
    load file
  end
end

invoke _default_stage if _stage_file_exists?(_default_stage) && !_argument_included_in_stages?(ARGV.first)

namespace :multistage do
  desc 'Create staging and production stage files'
  task :init do
    FileUtils.mkdir_p _stages_dir if !File.exists? _stages_dir
    %w{staging production}.each do |stage|
      stagefile = _file_for_stage(stage)
      if !_stage_file_exists?(stagefile)
        File.open(stagefile, 'w') do |f|
          f.puts "set :domain, ''"
          f.puts "set :deploy_to, ''"
          f.puts "set :repository, ''"
          f.puts "set :branch, ''"
          f.puts "set :user, ''"
        end
      end
    end
  end
end

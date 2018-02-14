require_relative './lib/kunkourse'

include Kunkourse

pipeline = Pipeline.from_file(File.join(__dir__, 'spec', 'fixtures', 'hello.yml'))
plan     = BuildPlanner::Job.new(job: pipeline.jobs.first).plan

states = {}

loop do
  puts 'Iterating over build plans'
  # are we done with the entire build plan
  break if %i[failed succesful].include? plan.state(states)

  # when there are more steps
  puts 'Calculating next steps'
  next_steps = plan.next(states)
  next_steps.each do |step|
    puts "\tstep: #{step}"
    step.execute!
    states[step] = :pending
  end

  # wait for those steps to be done (ie :failed or :success)
  print 'waiting for steps to complete'
  loop do
    next_steps.each do |step|
      next if step.pending?

      state[step] = :failed if step.failed?
      state[step] = :success if step.success?
    end
    break unless states.values.uniq.include?(:pending)
    sleep 5 # give it some breathing room
    print '.'
  end
  print "\n"
end

# done!!!

puts "Finished the job: #{plan.state(states)}"

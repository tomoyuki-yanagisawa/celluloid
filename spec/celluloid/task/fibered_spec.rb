RSpec.describe Celluloid::Task::Fibered, actor_system: :within do
  if Celluloid.task_class == Celluloid::Task::Fibered
    it_behaves_like "a Celluloid Task"
  end

  #de TODO: Test for different behavior based on 2.3.1 compatibility
end

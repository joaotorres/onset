# SPEC.md §5, Rate limits. The test environment's cache store is :null_store,
# which never counts, so the controllers' limits count in a MemoryStore instead.
# Every controller shares ActionController::Base's store object.
RSpec.shared_context "rate limits" do
  let(:store) { ActiveSupport::Cache::MemoryStore.new }

  before do
    allow(ActionController::Base.cache_store).to receive(:increment) { |*args, **opts| store.increment(*args, **opts) }
  end
end

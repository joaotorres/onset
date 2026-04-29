if Rails.env.production?
  Rails.application.config.after_initialize do
    ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).each do |config|
      next if config.primary?

      schema_file = Rails.root.join("db/#{config.name}_schema.rb")
      next unless schema_file.exist?

      begin
        conn = ActiveRecord::Base.establish_connection(config).connection
        unless conn.table_exists?("ar_internal_metadata")
          ActiveRecord::Schema.verbose = false
          load schema_file.to_s
        end
      rescue => e
        Rails.logger.error "Failed to ensure schema for #{config.name} database: #{e.message}"
      ensure
        ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      end
    end
  end
end

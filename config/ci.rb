# Run using bin/ci. Mirrors .github/workflows/ci.yml: run it before pushing.

CI.run do
  step "Setup", "bin/setup --skip-server"

  step "Style: Ruby", "bundle exec standardrb"

  step "Security: Gem audit", "bin/bundler-audit"
  step "Security: Importmap vulnerability audit", "bin/importmap audit"
  step "Security: Brakeman code analysis", "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error"
  step "Tests: RSpec", "bin/rails db:test:prepare tailwindcss:build && bundle exec rspec"
end

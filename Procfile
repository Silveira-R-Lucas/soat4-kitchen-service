web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml
consumer: bundle exec sidekiq -r ./app/workers/pagamento_event_consumer_worker.rb

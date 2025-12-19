FactoryBot.define do
  factory :order, class: 'Order' do
    id { SecureRandom.uuid }
    pedido_id { Faker::Number.number(digits: 4).to_s }
    items { [ { "item" => Faker::Food.dish, "quantity" => 1 } ] }
    status { 'RECEBIDO' }
    created_at { Time.now }
    updated_at { Time.now }

    initialize_with { new(**attributes) }
  end
end

module Api
  module V1
    class ProductionController < ApplicationController
      protect_from_forgery with: :null_session

      def enqueue
        repo = RedisOrderRepository.new
        use_case = EnqueueOrder.new(repo)
        order = use_case.execute(pedido_id: params.require(:pedido_id), items: params[:items] || [])
        render json: order.to_h, status: :created
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def next
        repo = RedisOrderRepository.new
        order = repo.pop_next
        if order
          render json: order.to_h
        else
          head :no_content
        end
      end

      def show
        repo = RedisOrderRepository.new
        order = repo.find_by_id(params[:id])
        if order
          render json: order.to_h
        else
          render json: { error: "Not found" }, status: :not_found
        end
      end

      def in_progress
        repo = RedisOrderRepository.new
        orders = repo.list_in_progress
        render json: orders.map(&:to_h)
      end

      def start
        repo = RedisOrderRepository.new
        uc = StartPreparation.new(repo)
        order = uc.execute(order_id: params[:id])
        render json: order.to_h
      end

      def ready
        repo = RedisOrderRepository.new
        uc = MarkReady.new(repo)
        order = uc.execute(order_id: params[:id])
        render json: order.to_h
      end

      def finalize
        repo = RedisOrderRepository.new
        uc = FinalizeOrder.new(repo)
        order = uc.execute(order_id: params[:id])
        render json: order.to_h
      end
    end
  end
end

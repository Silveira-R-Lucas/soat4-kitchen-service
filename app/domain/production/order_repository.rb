class OrderRepository
  def enqueue(order); raise NotImplementedError; end
  def pop_next; raise NotImplementedError; end
  def find_by_id(id); raise NotImplementedError; end
  def update(order); raise NotImplementedError; end
  def list_in_progress; raise NotImplementedError; end
end

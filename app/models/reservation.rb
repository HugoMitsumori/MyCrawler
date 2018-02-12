# Reservation
class Reservation
  include ActiveModel::Model
  attr_accessor :name, :date, :organization, :division
  attr_reader :rooms, :start_time, :finish_time, :members

  def rooms=(value)
    @rooms = value - ['0']
  end

  def start_time=(value)
    @start_time = value
    @start_time << ':00' if value.length < 8
  end

  def finish_time=(value)
    @finish_time = value
    @finish_time << ':00' if value.length < 8
  end

  def members=(value)
    @members = Integer(value)
  end
end

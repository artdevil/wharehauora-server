class SyncSensorsCount < ActiveRecord::Migration[5.1]
  def up
    Room.find_each do |room|
      Room.reset_counters(room.id, :sensors)
    end

    Home.find_each do |home|
      Home.reset_counters(home.id, :sensors)
    end
  end
end

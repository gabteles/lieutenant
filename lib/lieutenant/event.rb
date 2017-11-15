module Lieutenant
  class Event
    def initialize(uuid, version, data)
      @uuid = uuid
      @version = version
      @data = data
    end
  end
end

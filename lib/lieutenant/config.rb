module Lieutenant
  class Config
    extend Forwardable

    def initialize
      @registrations = {
        command_sender: CommandSender.new
      }
    end

    def respond_to_missing?(name, *)
      registration_method?(name) || super
    end

    def method_missing(name, *args, &block)
      return super unless registration_method?(name)
      args.empty? ? get(name) : set(name, *args)
    end

    private

    def_delegator :@registrations, :[], :get
    def_delegator :@registrations, :[]=, :set
    def_delegator :@registrations, :key?, :registration_method?
  end
end

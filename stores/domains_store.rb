class DomainsStore
  def initialize(factory)
    @store = factory.find_or_create('domains')
  end

  def add(attrs)
    name = attrs['name']
    @store.transaction do
      @store['domains'] ||= {}
      @store['domains'][name] = attrs
    end
  end

  def remove(name)
    @store.transaction do
      @store['domains'].delete(name)
    end
  end

  def all
    @store.transaction do
      @store['domains'].values
    end
  end

  def find(name)
    @store.transaction do
      @store['domains'][name] if @store['domains']
    end
  end

  def self.instance
    @@instance ||= DomainsStore.new(Store::Factory.instance)
  end
end
module DynamoRecord
  class Collection < Array

    def initialize(pager = nil, klass = nil)
      if pager && klass
        @pager = pager
        @klass = klass
        replace @pager.items.map { |item| klass.send(:from_database, item) }
      end
    end

    def next_page?
      @pager ? @pager.next_page? : false
    end

    def last_page?
      @pager ? @pager.last_page? : true
    end

    def next_page
      return self.class.new(@pager.next_page, @klass) if @pager.next_page?
      self.class.new
    end

    def each_page(&block)
      @pager.each do |page|
        yield self.class.new(page, @klass)
      end
    end
  end
end
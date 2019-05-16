module Yanapiri
  class MultiSourceConfig < Thor::CoreExt::HashWithIndifferentAccess
    def initialize(first, *others)
      super others.inject(first, &:merge)
    end
  end
end
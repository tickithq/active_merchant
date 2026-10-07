module ActiveMerchant
  module Versionable
    def self.included(base)
      if base.respond_to?(:class_attribute)
        base.class_attribute :versions, default: {}
        base.extend(ClassMethods)
      end
    end

    module ClassMethods
      def inherited(subclass)
        super
        subclass.versions = {}
      end

      def version(version, feature = :default_api)
        versions[feature] = version
      end

      # Each class keeps its own versions hash, so fall back to the superclass for a
      # feature the subclass does not set itself.
      def fetch_version(feature = :default_api)
        versions.fetch(feature) { superclass.fetch_version(feature) if superclass.respond_to?(:fetch_version) }
      end
    end

    def fetch_version(feature = :default_api)
      versions.fetch(feature) { self.class.fetch_version(feature) }
    end
  end
end

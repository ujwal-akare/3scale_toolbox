module ThreeScaleToolbox
  module Entities
    module Entity
      PRINTABLE_VARS = %w[
        id
      ].freeze

      VERBOSE_PRINTABLE_VARS = %w[
        id
      ].freeze

      public_constant :PRINTABLE_VARS
      public_constant :VERBOSE_PRINTABLE_VARS

      attr_accessor :verbose
      attr_reader :id, :attrs, :remote

      def initialize(id:, remote:, attrs: nil, verbose: false)
        @id = id
        @remote = remote
        @attrs = attrs
        @verbose = verbose
      end

      def to_s
        if @verbose
          format_vars(printable_attrs: self.class.const_get(:VERBOSE_PRINTABLE_VARS, inherit: true))
        else
          format_vars(printable_attrs: self.class.const_get(:PRINTABLE_VARS, inherit: true))
        end
      end

      private

      def format_vars(printable_attrs: nil)
        print_attrs = attrs.merge({ ":id" => @id })
        formatted_vars = printable_attrs.map do |attr|
          "#{attr} => #{attrs[attr]}"
        end
        formatted_vars.join("\n")
      end
    end
  end
end

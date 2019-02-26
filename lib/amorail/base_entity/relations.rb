module Amorail
  module Entities
    module Relations
      extend ActiveSupport::Concern

      included do
        def relation_klass(entity)
          singular_klass_name = ActiveSupport::Inflector.singularize(entity.to_sym)
          klass_name = ActiveSupport::Inflector.classify(singular_klass_name)
          ActiveSupport::Inflector.constantize(['Amorail', klass_name].join('::'))
        end
      end

      class_methods do
        def relations
          @relations ||= if superclass.respond_to?(:relations)
                           superclass.relations.dup
                         else
                           {
                             regular_belongs_to: {},
                             regular_has_many: {},
                             polymorphic_has_many: {}
                           }
                         end
        end

        def amo_belongs_to(entity, options = {})
          if options[:polymorphic_to].nil?
            relations[:regular_belongs_to][entity] = options
            amo_attribute(options[:foreign_key] || "#{entity}_id".to_sym)

            class_eval <<~RUBY, __FILE__, __LINE__ + 1
              def #{entity}
                relation_options = self.class.relations[:regular_belongs_to]['#{entity}'.to_sym]
                relation_klass('#{entity}').
                  where(relation_options[:foreign_key] || '#{entity}_id' => #{entity}_id).first
              end
            RUBY
          else
            amo_attribute :element_id
            amo_attribute :element_type

            validates :element_id, presence: true
            validates :element_type, presence: true
            validates :element_type, inclusion: {
              in: options[:polymorphic_to].map {|klass| klass.constantize::AMO_ENTITY_CODE}
            }
          end
        end

        def amo_has_many(entity, options = {})
          if options[:polymorphic]
            relations[:polymorphic_has_many][entity] = options
            polymorphic_has_many_relation(entity, options)
          else
            relations[:regular_has_many][entity] = options
            regular_has_many_relation(entity, options)
          end
        end

        private

        def polymorphic_has_many_relation(entity, _options = {})
          # METAMAGIC
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{entity}
              relation_options = self.class.relations[:polymorphic_has_many]['#{entity}'.to_sym]
              relation_klass('#{entity}').where(element_id: id, element_type: AMO_ENTITY_CODE)
            end
          RUBY
        end

        def regular_has_many_relation(entity, options = {})
          # Register attribute for communicating with field
          amo_attribute(
            "#{entity}_id".to_sym,
            type: options[:as_array] ? :default : :serialized_array
          )

          # METAMAGIC
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{entity}
              relation_options = self.class.relations[:regular_has_many]['#{entity}'.to_sym]

              ids = public_send('#{entity}_id')
              relation_klass('#{entity}').where(id: ids)
            end

            def #{entity}_id=(ids = [])
              if @#{entity}_id.nil?
                @#{entity}_id = ids
              else
                @#{entity}_id = (@source_#{entity}_id & ids) + (ids - @source_#{entity}_id & ids)
              end
            end
          RUBY
        end
      end
    end
  end
end

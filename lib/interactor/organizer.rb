# frozen_string_literal: true

module Interactor
  # Public: Interactor::Organizer methods. Because Interactor::Organizer is a
  # module, custom Interactor::Organizer classes should include
  # Interactor::Organizer rather than inherit from it.
  #
  # Examples
  #
  #   class MyOrganizer
  #     include Interactor::Organizer
  #
  #     organizer InteractorOne, InteractorTwo
  #   end
  module Organizer
    # Internal: Install Interactor::Organizer's behavior in the given class.
    def self.included(base)
      base.class_eval do
        include Interactor

        extend ClassMethods
        include InstanceMethods
      end
    end

    # Internal: Interactor::Organizer class methods.
    module ClassMethods
      # Public: Declare Interactors to be invoked as part of the
      # Interactor::Organizer's invocation. These interactors are invoked in
      # the order in which they are declared.
      #
      # interactors - Zero or more (or an Array of) Interactor classes or hashes with
      #               a key :interactor and an optional :if with a symbol for a method name
      #               which gets called on the instance to check if an interactor should be run
      #
      # Examples
      #
      #   class MyFirstOrganizer
      #     include Interactor::Organizer
      #
      #     organize InteractorOne, InteractorTwo
      #   end
      #
      #   class MySecondOrganizer
      #     include Interactor::Organizer
      #
      #     organize [InteractorThree, InteractorFour]
      #   end
      #
      #   class MySecondOrganizer
      #     include Interactor::Organizer
      #
      #     organize { interactor: InteractorThree, if: :user_missing? }, { interactor: InteractorFour }
      #
      #     private
      #
      #     def user_missing?
      #       context.user.blank?
      #     end
      #   end
      #
      # Returns nothing.
      def organize(*interactors)
        @organized = interactors.flatten.map do |interactor|
          if interactor.is_a?(Hash)
            interactor
          else
            { interactor: interactor }
          end
        end
      end

      # Internal: An Array of declared Interactors to be invoked.
      #
      # Examples
      #
      #   class MyOrganizer
      #     include Interactor::Organizer
      #
      #     organize { interactor: InteractorOne }, { interactor: InteractorTwo, if: :user_missing? }
      #   end
      #
      #   MyOrganizer.organized
      #   # => [{ interactor: InteractorOne }, { interactor: InteractorTwo, if: :user_missing? }]
      #
      # Returns an Array of Interactor classes or an empty Array.
      def organized
        @organized ||= []
      end
    end

    # Internal: Interactor::Organizer instance methods.
    module InstanceMethods
      # Internal: Invoke the organized Interactors. An Interactor::Organizer is
      # expected not to define its own "#call" method in favor of this default
      # implementation.
      #
      # Returns nothing.
      def call
        self.class.organized.each do |interactor|
          if interactor[:if]
            next unless send(interactor[:if])
          end
          interactor[:interactor].call!(context)
        end
      end
    end
  end
end

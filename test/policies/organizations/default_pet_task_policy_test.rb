require "test_helper"

# See https://actionpolicy.evilmartians.io/#/testing?id=testing-policies
class Organizations::DefaultPetTaskPolicyTest < ActiveSupport::TestCase
  include PetRescue::PolicyAssertions

  context "context only action" do
    setup do
      @organization = ActsAsTenant.current_tenant
      @policy = -> {
        Organizations::DefaultPetTaskPolicy.new(DefaultPetTask, person: @person, user: @person&.user)
      }
    end

    context "#manage?" do
      setup do
        @action = -> { @policy.call.apply(:manage?) }
      end

      context "when user is nil" do
        setup do
          @person = nil
        end

        should "return false" do
          assert_equal false, @action.call
        end
      end

      context "when user is adopter" do
        setup do
          @person = create(:person, :adopter)
        end

        should "return false" do
          assert_equal false, @action.call
        end
      end

      context "when user is fosterer" do
        setup do
          @person = create(:person, :fosterer)
        end

        should "return false" do
          assert_equal false, @action.call
        end
      end

      context "when user is admin" do
        setup do
          @person = create(:person, :admin)
        end

        should "return true" do
          assert_equal true, @action.call
        end
      end

      context "when user is super admin" do
        setup do
          @person = create(:person, :super_admin)
        end

        should "return true" do
          assert_equal true, @action.call
        end
      end

      context "when user is deactivated staff" do
        setup do
          @person = create(:person, :admin, deactivated: true)
        end

        should "return false" do
          assert_equal false, @action.call
        end
      end
    end

    context "#index?" do
      should "be an alias to :manage?" do
        assert_alias_rule @policy.call, :index?, :manage?
      end
    end

    context "#new?" do
      should "be an alias to :manage?" do
        assert_alias_rule @policy.call, :new?, :manage?
      end
    end

    context "#create?" do
      should "be an alias to :manage?" do
        assert_alias_rule @policy.call, :create?, :manage?
      end
    end
  end

  context "existing record action" do
    setup do
      @default_task = create(:default_pet_task)
      @policy = -> {
        Organizations::DefaultPetTaskPolicy.new(@default_task, person: @person, user: @person&.user)
      }
    end

    context "#manage?" do
      setup do
        @action = -> { @policy.call.apply(:manage?) }
      end

      context "when user is nil" do
        setup do
          @person = nil
        end

        should "return false" do
          assert_equal false, @action.call
        end
      end

      context "when user is adopter" do
        setup do
          @person = create(:person, :adopter)
        end

        should "return false" do
          assert_equal false, @action.call
        end
      end

      context "when user is fosterer" do
        setup do
          @person = create(:person, :fosterer)
        end

        should "return false" do
          assert_equal false, @action.call
        end
      end

      context "when user is admin" do
        setup do
          @person = create(:person, :admin)
        end

        context "when default pet task belongs to a different organization" do
          setup do
            ActsAsTenant.with_tenant(create(:organization)) do
              @default_task = create(:default_pet_task)
            end
          end

          should "return false" do
            assert_equal false, @action.call
          end
        end

        context "when default pet task belongs to user's organization" do
          should "return true" do
            assert_equal true, @action.call
          end
        end
      end

      context "when user is deactivated staff" do
        setup do
          @person = create(:person, :admin, deactivated: true)
        end

        should "return false" do
          assert_equal false, @action.call
        end
      end

      context "when user is super admin" do
        setup do
          @person = create(:person, :super_admin)
        end

        context "when default pet task belongs to a different organization" do
          setup do
            ActsAsTenant.with_tenant(create(:organization)) do
              @default_task = create(:default_pet_task)
            end
          end

          should "return false" do
            assert_equal false, @action.call
          end
        end

        context "when default pet task belongs to user's organization" do
          should "return true" do
            assert_equal true, @action.call
          end
        end
      end
    end

    context "#edit?" do
      should "be an alias to :manage?" do
        assert_alias_rule @policy.call, :edit?, :manage?
      end
    end

    context "#update?" do
      should "be an alias to :manage?" do
        assert_alias_rule @policy.call, :update?, :manage?
      end
    end

    context "#destroy?" do
      should "be an alias to :manage?" do
        assert_alias_rule @policy.call, :destroy?, :manage?
      end
    end
  end
end

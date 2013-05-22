class Ability
  include CanCan::Ability

  def initialize(user, current_tenant)
    user ||= User.new # guest user (not logged in)
    if user.has_role? :admin
      can :manage, :all
    elsif user.has_role? :admin, current_tenant
      can :manage, :all
      cannot :create, Account
    elsif user.has_role? :editor, current_tenant
      can :manage, :all
      cannot :destroy, :all
      cannot :create, User
      cannot :manage, Account
    else
      can :read, :all
      can :create, Session
    end

    # Global admin can do everything
    # Instance admin can do everything but create new instances
    # Editors can't destroy items nor administrate users and instances
  end
end

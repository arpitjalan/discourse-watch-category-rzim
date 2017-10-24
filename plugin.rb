# name: Watch Category
# about: Watches a category for all the users in a particular group
# version: 0.3
# authors: Arpit Jalan
# url: https://github.com/techapj/discourse-watch-category-rzim

module ::WatchCategory
  def self.watch_category!
    swad_category = Category.find_by_slug("swad")
    swad_group = Group.find_by_name("SWAD")

    ncmls_steering_category = Category.find_by_slug("ncmls-steering-committee")
    ncmls_steering_group = Group.find_by_name("NCMLS_Steering")

    # mute all categories
    Category.find_each do |cat|
      unless cat.id == swad_category.id
        swad_group.users.each do |user|
          muted_categories = CategoryUser.lookup(user, :muted).pluck(:category_id)
          CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:muted], cat.id) unless muted_categories.include?(cat.id)
        end
      end

      unless cat.id == ncmls_steering_category.id
        ncmls_steering_group.users.each do |user|
          muted_categories = CategoryUser.lookup(user, :muted).pluck(:category_id)
          CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:muted], cat.id) unless muted_categories.include?(cat.id)
        end
      end
    end

    # watch SWAD category
    unless swad_category.nil? || swad_group.nil?
      swad_group.users.each do |user|
        user.user_option.update_columns(mailing_list_mode: true)
        watched_categories = CategoryUser.lookup(user, :watching).pluck(:category_id)
        CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:watching], swad_category.id) unless watched_categories.include?(swad_category.id)
      end
    end

    # watch "NCMLS Steering Committee" category
    unless ncmls_steering_category.nil? || ncmls_steering_group.nil?
      ncmls_steering_group.users.each do |user|
        user.user_option.update_columns(mailing_list_mode: true)
        watched_categories = CategoryUser.lookup(user, :watching).pluck(:category_id)
        CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:watching], ncmls_steering_category.id) unless watched_categories.include?(ncmls_steering_category.id)
      end
    end
  end
end

after_initialize do
  module ::WatchCategory
    class WatchCategoryJob < ::Jobs::Scheduled
      every 1.month

      def execute(args)
        WatchCategory.watch_category!
      end
    end
  end
end
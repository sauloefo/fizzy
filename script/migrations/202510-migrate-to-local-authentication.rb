#!/usr/bin/env ruby

#
#  set up a temporary password for all users
#  while we migrate away from Launchpad and 37id.
#
#  the password is unguessable but generated based on the email address and a seed,
#  so each user will have the same password across all tenants.
#
require_relative "../../config/environment"

seed = ARGV[0] || "temporary-password-seed"
puts "Using seed: #{seed.inspect}"

TENANTS = Hash.new
USERS = Hash.new { |h, k| h[k] = Hash.new }

ApplicationRecord.with_each_tenant do |tenant|
  TENANTS[tenant] = Account.sole.name

  User.find_each do |user|
    putc "."
    next if user.system?

    if user.external_user_id
      suser = SignalId::User.find_by_id(user.external_user_id)
      if suser && suser.email_address != user.email_address
        puts "\nWarning: fixing email address for user #{user.id} in tenant #{tenant}:"
        puts "  local:  #{user.email_address}"
        puts "  signal: #{suser.email_address}"
        user.update! email_address: suser.email_address
      end
    end

    password = Digest::SHA256.hexdigest("#{seed}-#{user.email_address}")[0..16]
    user.update! password: password

    USERS[user.email_address][tenant] = password
  end
end

puts

USERS.each do |email, hash|
  puts "\n#{email}:"
  puts "  password: #{hash.first.last}"
  puts "  fizzies:"
  hash.each do |tenant, _|
    url = Rails.application.routes.url_helpers.root_url(Rails.application.config.action_controller.default_url_options.merge(script_name: "/#{tenant}"))

    puts "    #{TENANTS[tenant]}: #{url}"
  end
end

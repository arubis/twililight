require 'twilio-ruby'
require 'awesome_print'
require 'pry'
require 'dotenv/load'

account_sid = ENV['ACCOUNT_SID']
auth_token = ENV['AUTH_TOKEN']

@client = Twilio::REST::Client.new(account_sid, auth_token)

# A Twilio account has Services (like environments).
# Services have Bindings that cross-associate between a Service, a user, and
#   a set of notification preferences. One can also specify a destination for a
#   notification directly on the notif itself; we'll try this first.

def notify_service(name = 'development')
  # not atomic! lookup and create are separate transactions.
  # do not reuse (any of) this code outside of dev.
  notify_svcs = @client.notify.services

  @notify_service ||= notify_svcs.list(friendly_name: name).first ||
                      notify_svc.create(friendly_name: name)
end

def update_notify_service!
  @notify_service = @client.notify.services(notify_service.sid).fetch
end

def messaging_service(name = 'messaging dev')
  @messaging_service ||= @client.messaging.services.list
                                .select { |svc| svc.friendly_name == name }
                                .first ||
                         @client.messaging.services.create(friendly_name: name)
end

# def associate_messaging_service_with_phone_number(msg_svc = messaging_service,
#                                                   ph_number = outgoingNumber)
#   puts "hey user, go do this in the Twilio console"
#   puts "their API doesn't support this action yet :( :( :("
# end

def associate_notify_with_messaging_service
  unless notify_service.messaging_service_sid
    notify_service.update(messaging_service_sid: messaging_service.sid)
    update_notify_service!
  end
end

# IMPORTANT: Existing Bindings with the same Address are _Replaced_
# https://www.twilio.com/docs/notify/api/binding-resource#existing-bindings-with-the-same-address-are-replaced
# This has implications for users that have multiple logins--unless we unify
# user records for contact info, only one Address record will work as expected.
#
# ALSO IMPORTANT: there is no `update` method or endpoint for bindings. If you
# want to change an existing binding, you must delete and re-create it.
def personal_bindings
  personal_bindings = notify_service.bindings.list(identity: '1')
  if personal_bindings.empty?
    [] << notify_service
          .bindings
          .create(
            identity: '1',
            # can be apn (ios), fcm (firebase), gcm (google cloud),
            # sms, facebook-messenger:
            binding_type: 'sms',
            address: ENV['PHONE_DEST'],
            # freeform strings to use when filtering which binding
            # to choose when sending notif:
            tag: ['preferred']
          )
  else
    personal_bindings
  end
end

binding.pry

puts personal_bindings[0]


# notifies _all_ methods associated with identity: 1
# notification = notify_service.notifications.create(body: "Hello, world!",
#                                                    identity: '1')

# notifies methods tagged 'preferred' associated with identity 1
notification = notify_service.notifications.create(body: 'Hello, small world!',
                                                   identity: '1',
                                                   tag: 'preferred')
puts notification.sid

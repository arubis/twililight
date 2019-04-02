# TwiliLight

Seriously just barely enough code to send an SMS notification using Twilio's Notify API.
I'm using a `binding.pry` to give you a prompt to do stuff. Really, this is minimal.

## Configuration & First Use

Get a Twilio account. Make sure it's got a little credit in it. Purchase an outgoing number. Pull out your API credentials.

Create a `.env` file in this directory, as follows:

```sh
# Twilio credentials
ACCOUNT_SID="ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
AUTH_TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Destination phone number -- should be yours!
PHONE_DEST="+18888675309"
```

Run the script: `ruby ./twililight.rb`. You'll end up in a Pry shell from the call to `binding.pry`. Yay! You'll want to provisiong a Notify service and a Messaging service. Within the Pry console, do a:
```ruby
> notify_service
#<Twilio::REST::Notify::V1::lots of other good stuff>
=> (the service object)

> messaging_service
=> <Twilio.Messaging.V1.ServiceInstance sid: blah and lots more info>
```

Now head to the [Messaging Services web console](https://www.twilio.com/console/sms/services). Apparently there isn't currently a way to associate a Messaging Service with a purchased phone number through the API, which is (a) a major bummer and (b) I'm not totally convinced this is even true, as a former employer was definitely auto-provisioning a ton of numbers without human intervention. We'll save that battle for another day, though--for now, click on the messaging service (named `messaging dev` if you just used the defaults here), select Numbers in the sidebar, and add the number your purchased earlier.

Nice.

Head back into the Pry session (it's cool if you need to restart it), and fire off a call to `associate_notify_with_messaging_service`.

Now if you `continue` or Ctrl+D to get out of Pry and continue the script, it should complete successfully, and you should get a text at the number you supplied in .env.

## Ongoing Usage

After a first successful run & provisioning as described above, running the script straight through without additional calls (and either `continue`ing past the `binding.pry` or just commenting it out) will fire off another SMS notification.

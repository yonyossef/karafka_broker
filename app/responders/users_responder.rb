# Class UsersResponder < ApplicationResponder
#   # topic :users

#   # def respond(event_payload)
#   #   respond_to :users, event_payload
#   # end
# end

class UsersResponder < ApplicationResponder
  # This method needs to be implemented in each of the responders
  topic :users

  def respond(event_payload)
    respond_to :users, event_payload
  end
end
class ApplicationController < ActionController::Base
  include Authentication
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private
    def record_not_found
      render plain: "Not found", status: :not_found
    end
end

module Disclosure
  # A tech contact whose `kind` is 'org' reveals name/email/phone at the
  # detailed level. A missing `kind` means the contact is not an org.
  class TechContactPresenter < ContactPresenter
    private

    def org_details_at_detailed?
      @contact['kind'] == 'org'
    end
  end
end

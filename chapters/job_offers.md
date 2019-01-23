## Job Offers


### Refine the model


Since we are now basically done with the user management, it's time to model our `JobOffer` model.

Specs first:


```ruby
# spec/app/models/job_offer_spec.rb

require 'spec_helper'

RSpec.describe JobOffer do
  let(:job_offer) { build_stubbed(:job_offer) }
  let(:wrong_job_offer) { JobOffer.new }

  it 'can be created' do
    expect(job_offer).not_to be_nil
  end

  it 'must have a title' do
    wrong_job_offer.title = ''
    wrong_job_offer.description = 'hallo'

    expect(wrong_job_offer.valid?).to be_falsey
  end

  it 'must have a description' do
    wrong_job_offer.title = 'Hallo'
    wrong_job_offer.description = ''

    expect(wrong_job_offer.valid?).to be_falsey
  end

  it 'must have a location' do
    wrong_job_offer.title = 'Hallo'
    wrong_job_offer.description = 'hallo'
    expect(wrong_job_offer.valid?).to be_falsey
  end

  it 'must have a contact' do
    wrong_job_offer.title = 'Hallo'
    wrong_job_offer.description = 'hallo'
    wrong_job_offer.location = 'Berlin'
    wrong_job_offer.contact = ''
    expect(wrong_job_offer.valid?).to be_falsey
  end

  it 'must have a time_start' do
    wrong_job_offer.title = 'Hallo'
    wrong_job_offer.description = 'hallo'
    wrong_job_offer.location = 'Berlin'
    wrong_job_offer.contact = 'Test'
    expect(wrong_job_offer.valid?).to be_falsey
  end

  it 'must have a time_end' do
    wrong_job_offer.title = 'Hallo'
    wrong_job_offer.description = 'hallo'
    wrong_job_offer.location = 'Berlin'
    wrong_job_offer.contact = 'Test'
    wrong_job_offer.time_start = '2019/01/16'
    expect(wrong_job_offer.valid?).to be_falsey
  end

  it 'time_start cannot be bigger then time_end' do
    wrong_job_offer.title = 'Hallo'
    wrong_job_offer.description = 'hallo'
    wrong_job_offer.location = 'Berlin'
    wrong_job_offer.contact = 'Test'
    wrong_job_offer.time_start = '2019/01/17'
    wrong_job_offer.time_end = '2019/01/16'
    expect(wrong_job_offer.valid?).to be_falsey
  end

  it 'must be related to a user' do
    expect(job_offer.user).to be_nil
    job_offer.build_user({id: 100})
    expect(job_offer.user.id).to eq 100
  end
end
```


The special thing about this spec is that we have to ensure that the `time_start` value is not lower then the `time_end` value.
We will do this with the [validates method](https://api.rubyonrails.org/v5.2.2/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates "validates method") to have a custom validation:


```ruby
# app/models/job_offer.rb
class JobOffer < ActiveRecord::Base
  belongs_to :user

  validates :title,
    :description,
    :location,
    :contact,
    :time_start,
    :time_end,
    presence: true

  validate :dates

  private
  def dates
    if time_start && time_end && time_start > time_end
      errors.add(:time_end, 'must be after time_start')
    end
  end
end
```


The `errors.add` method will add an error to the model to the `:time_end` property with a custom
message.



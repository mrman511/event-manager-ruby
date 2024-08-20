require 'rails_helper'

RSpec.describe User, type: :model do
  email="bodner80@gmail.com"
  password="password"
  let(:user) {
    User.create(email: email)
  }

  it 'raises ActiveRecord::RecordInvalid when no email is given' do
    expect { User.create!.to raise_error(ActiveRecord::RecordInvalid) }
  end

  it "is valid with valid attributes, when email is the only attribute given" do
    expect { :user.to be_valid }
  end

  it "raises when attempting to create second user with same email" do
    expect { User.create(email: email).to raise_error(ActiveRecord::RecordInvalid) }
  end

  it "returns only 1 instance of given email after attempting to create a second" do
    expect { User.where(email: email).count.to eq(1) }
  end

  it "removes a record from the database" do
    user.destroy
    expect { user.reload.to raise_error(ActiveRecord::RecordNotFound) }
  end
end

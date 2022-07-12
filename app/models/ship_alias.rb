class ShipAlias < ApplicationRecord
  enum status: {
    un_approved: 0,
    approved: 1
  }
end

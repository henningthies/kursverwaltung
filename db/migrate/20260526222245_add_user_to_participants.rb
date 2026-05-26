class AddUserToParticipants < ActiveRecord::Migration[8.1]
  def change
    # Optional: Alt-Anmeldungen ohne Konto bleiben bestehen; neue Käufe referenzieren einen User.
    add_reference :participants, :user, null: true, foreign_key: true
  end
end

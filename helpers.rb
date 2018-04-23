require 'sequel'

def generate_db()
    db = Sequel.connect("sqlite://data/bank.db")
    db.create_table? :bank do
        primary_key :id
        String :uid
        String :name
        String :pin
        Float :balance
    end
    return db
end

def delete_db()
   File.delete("data/bank.db")
end

def retrieve_user(id)
    db = Sequel.connect("sqlite://data/bank.db")
    bank = db[:bank]
    user = bank[uid: id]
    if user != nil
        return user
    else
        return false
    end
end

def retrieve_all()
    db = generate_db()
    bank = db[:bank]
    arr = []
    bank.each{|row| arr.push(row[:uid])}
    return arr
end

def create_user(id, nme, bal, pinn)
    db = Sequel.connect("sqlite://data/bank.db")
    bank = db[:bank]
    user = bank[uid: id]
    if user == nil
        bank.insert(uid: id, name: nme, balance: bal, pin: pinn)
        user = bank[uid: id]
        if user == nil
            return false
        else
            return user
        end
    else
        return false
    end
end

def delete_user(id)
    db = Sequel.connect("sqlite://data/bank.db")
    bank = db[:bank]
    user = bank[uid: id]
    if user != nil
        bank.where(uid: id).delete
        return true
    else
        return false
    end
end

def add_bal(id, amt)
    db = Sequel.connect("sqlite://data/bank.db")
    bank = db[:bank]
    user = bank[uid: id]
    if user != nil
        ubal = user[:balance]
        if amt > 0
            bank.where(uid: id).update(balance: ubal.to_f + amt.to_f)
            return bank[uid: id][:balance]
        else
            return false
        end
    else
        return false
    end
end

def remove_bal(id, amt)
    db = Sequel.connect("sqlite://data/bank.db")
    bank = db[:bank]
    user = bank[uid: id]
    if user != nil
        ubal = user[:balance]
        if amt > 0 && (ubal.to_f - amt.to_f) > 0
            bank.where(uid: id).update(balance: ubal.to_f - amt.to_f)
            return bank[uid: id][:balance]
        else
            return false
        end
    end
end

def check_bal(id)
    db = Sequel.connect("sqlite://data/bank.db")
    bank = db[:bank]
    user = bank[uid: id]
    if user != nil
        return user[:balance]
    else
        return false
    end
end

def get_name(id)
    db = Sequel.connect("sqlite://data/bank.db")
    bank = db[:bank]
    user = bank[uid: id]
    return user[:name]
end

def transfer_money(frid, toid, amt)
    db = Sequel.connect("sqlite://data/bank.db")
    bank = db[:bank]
    fruser = bank[uid: frid]
    touser = bank[uid: toid]
    if fruser != nil && touser != nil && fruser != touser
        if fruser[:balance] >= amt
            bank.where(uid: frid).update(balance: (fruser[:balance].to_f - amt.to_f))
            bank.where(uid: toid).update(balance: (touser[:balance].to_f + amt.to_f))
            return true
        else
            return false
        end
    else
        return false
    end
end

def adminlogin(pass)
   if pass != "admin"
       return false
   else
       return true
   end
end

def userlogin(id, pinn)
    db = Sequel.connect("sqlite://data/bank.db")
    bank = db[:bank]
    user = bank[uid: id]
    pin = user[:pin]
    if pin == pinn
        return true
    else
        return false
    end
end

def clear_screen()
  if RUBY_PLATFORM =~ /win32|win64|\.NET|windows|cygwin|mingw32/i
    system('cls')
  else
    system('clear')
  end
end

def check_format(id)
    splid = id.split('-')
    if splid.join.length == 8
        return true
    else
        return false
    end
end

def user_exist?(id)
    if check_format(id)
        if retrieve_user(id) != false
            return true
        else
            return false
        end
    else
        return false
    end
end
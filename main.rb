# Require needed gems
require 'sequel'
require 'highline'
require 'io/console'

# Obtain the helpers
require_relative 'helpers.rb'

# Clear the screen to make it look good.
clear_screen()

# Generate the DB for other purposes, as
#   every function internally gets the DB
#   for it's own use, which means in theory
#   this DB never has to be accessed from
#   this file.
DB = generate_db()
cli = HighLine.new

# More Aesthetics
clear_screen()

# Start Actual Program
while true do
    print "\n\n\n\nPlease enter your bank number:\n       "
    idin = gets.chomp
    if idin != "exit" && idin != "admin" && idin != nil && check_format(idin)
        if user_exist?(idin) != false
            puts;puts
            passin = cli.ask("Please enter your pin number: ") { |q| q.echo = "*" }
            if userlogin(idin, passin)
                clear_screen()
                while true do
                    puts "#{get_name(idin)}\nPlease choose an option."
                    cli.choose do |menu|
                        menu.choice(:"Check Balance") { $opt = 1}
                        menu.choice(:"Transfer Money") { $opt = 2}
                        menu.choice(:"Exit") { $opt = 0 }
                    end
                    case $opt
                    when 1
                        clear_screen()
                        puts "Current Balance " + check_bal(idin).to_s
                    when 2
                        touser = cli.ask("Who would you like to transfer money to? ")
                        if check_format(touser)
                           toammt = cli.ask("How much money would you like to transfer? ").to_f
                           confirm = cli.ask("Is this information correct (Y/n)?  ") { |q| q.default="y" }
                           if confirm.downcase == "y"
                               transf = transfer_money(idin, touser, toammt)
                               if transf
                                   puts "Success"
                                   sleep 2
                                   clear_screen()
                               else
                                   puts "Failed"
                                   sleep 2
                                   clear_screen()
                               end
                           else
                               puts "Aborted"
                               sleep 2
                               clear_screen()
                           end
                        else
                            puts "Invalid ID"
                            sleep 2
                            clear_screen()
                        end
                    when 0
                        clear_screen()
                        break
                    end
                end
            else
                clear_screen()
            end
        else
            puts;puts
            opt = cli.ask("This ID isn't registered, would you like to register it?\n1 To register\n2 To quit")
            if opt.to_i == 1
                name = cli.ask("\n\nRegistration Menu:\nWhat is your name?  ")
                pinn = cli.ask("What would you like your pin number to be?  ") { |q| q.echo="*"}
                pinnn= cli.ask("Please enter your pin number again:         ") { |q| q.echo="*"}
                if pinn.to_i == pinnn.to_i && pinn.to_i != 0 && pinnn.to_i != 0
                    puts "Registration info:\nName:             #{name}\nPin (chars long): #{pinn.length}"
                    bal = cli.ask("How much money will you be depositing today? ")
                    ball = bal.to_f
                    if ball > 0.1
                        puts "Starting Balance: #{ball}"
                        while true do
                            good = cli.ask("Is this information correct (Y/n)?  ") { |q| q.default="y" }
                            good = good.downcase
                            case good
                            when "y","yes"
                                print "Registering User"
                                8.times do
                                    sleep 0.2
                                    print "."
                                end
                                create_user(idin, name, ball, pinn)
                                print "..  User Registered!"
                                sleep 1.4
                                clear_screen()
                                break
                            when "n","no"
                                puts "Aborting action."
                                sleep 2
                                clear_screen()
                                break
                            else
                                puts "Invalid selection"
                            end
                        end
                    elsif bal == "exit"
                        puts "Exiting menu"
                        sleep 1.5
                        clear_screen()
                    else
                        puts "Invalid number, aborting"
                        sleep 1.5
                        clear_screen()
                    end
                else
                    puts "Pin number did not match, aborting"
                end
            else
                clear_screen()
            end
        end
    elsif idin == "admin"
        pass = cli.ask("Please enter the admin password: ") { |q| q.echo="*" }
        if adminlogin(pass)
            clear_screen()
            while true do
                puts "Please choose an option: "
                cli.choose do |menu|
                    menu.choice(:"Check the balance of an account") { $opt = 0 }
                    menu.choice(:"See all accounts") { $opt = 7 }
                    menu.choice(:"Add money to an account") { $opt = 1 }
                    menu.choice(:"Remove money from an account") { $opt = 2 }
                    menu.choice(:"Create an account") { $opt = 6 }
                    menu.choice(:"Delete an account") { $opt = 3 }
                    menu.choice(:"Delete DB and Regenerate") { $opt = 5 }
                    menu.choice(:"Exit") { $opt = 4 }
                end
                case $opt
                when 0
                    iddin = cli.ask("What account would you like to see the balance of? ")
                    if user_exist?(iddin)
                        clear_screen()
                        puts "Balance of #{iddin}: #{check_bal(iddin).to_f}\nName on account: #{get_name(iddin)}\n\n"
                    elsif check_format(iddin)
                        puts "User does not exist"
                        sleep 2
                        clear_screen()
                    elsif !check_format(iddin)
                        puts "Invalid ID format"
                        sleep 2
                        clear_screen()
                    end
                when 1
                    iddin = cli.ask("What account would you like to add to?")
                    if user_exist?(iddin)
                        add = cli.ask("How much would you like to add?")
                        add = add.to_f
                        if add > 0.0
                            confirm = cli.ask("Are you sure? ") { |q| q.default="y" }
                            if confirm == "y"
                                if add_bal(iddin, add)
                                    puts "Success"
                                    sleep 2
                                    clear_screen()
                                else
                                    puts "Failed"
                                    sleep 2
                                    clear_screen()
                                end
                            else
                                puts "Action aborted."
                                sleep 2
                                clear_screen()
                            end
                        else
                            puts "Invalid number."
                            sleep 2
                            clear_screen()
                        end
                    elsif !retrieve_user(iddin) && check_format(iddin)
                        puts "User does not exist"
                        sleep 2
                        clear_screen()
                    elsif !check_format(iddin)
                        puts "Invalid ID format"
                        sleep 2
                        clear_screen()
                    end    
                when 2
                    iddin = cli.ask("What account would you like to remove money from?")
                    if user_exist?(iddin)
                        remove = cli.ask("How much would you like to remove?")
                        remove = remove.to_f
                        if remove > 0.0
                            confirm = cli.ask("Are you sure? ") { |q| q.default="y" }
                            if confirm == "y"
                                if remove_bal(iddin, remove)
                                    puts "Success"
                                    sleep 2
                                    clear_screen()
                                else
                                    puts "Failed"
                                    sleep 2
                                    clear_screen()
                                end
                            else
                                puts "Action aborted."
                                sleep 2
                                clear_screen()
                            end
                        else
                            puts "Invalid number."
                            sleep 2
                            clear_screen()
                        end
                    elsif check_format(iddin)
                        puts "User does not exist"
                        sleep 2
                        clear_screen()
                    elsif !check_format(iddin)
                        puts "Invalid ID format"
                        sleep 2
                        clear_screen()
                    end    
                when 3
                    iddin = cli.ask("Which account would you like to delete? ")
                    if user_exist?(iddin)
                        confirm = cli.ask("Are you sure you would like to delete this account (#{iddin})? ") { |q| q.default = "y" }
                        if confirm == "y"
                            delete_user(iddin)
                            puts "Account deleted!"
                            sleep 2
                            clear_screen()
                        else
                            puts "Action Aborted!"
                            sleep 2
                            clear_screen()
                        end
                    else
                       puts "Account does not exist"
                       sleep 2
                       clear_screen()
                    end
                when 5
                    confirm = cli.ask("Are you sure you would like to regenerate the DB? ") { |q| q.default="y" }
                    if confirm == "y"
                        print "Deleting DB."
                        8.times do
                            print "."
                            sleep 0.05
                        end
                        delete_db()
                        puts "\nDB Deleted!"
                        print "Regnerating DB."
                        8.times do
                            print "."
                            sleep 0.05
                        end
                        generate_db()
                        puts "\nDB Regenerated!"
                        puts;puts;puts "Finished"
                        sleep 2
                        clear_screen()
                    else
                       puts "Action aborted"
                       sleep 2
                       clear_screen()
                    end
                when 4
                    print "\nSigning out.."
                    8.times do
                       sleep 0.09
                       print "."
                    end
                    print ".. Signed out!\n"
                    sleep 2
                    clear_screen()
                    break
                when 6
                    while true do
                        iddin = cli.ask("What will the ID number be? ")
                        if !user_exist?(iddin) && check_format(iddin)
                            name = cli.ask("What will the name on the account be? ")
                            pin = cli.ask("What will the pin number be? ") { |q| q.echo="*" }
                            bal = cli.ask("How much money will the account start with? ")
                            puts "ID Number:        #{iddin}\n"\
                                 "Name on account:  #{name}\n"\
                                 "Pin (chars long): #{pin.length}\n"\
                                 "Starting balance: #{bal.to_f}"
                            correct = cli.ask("Is this information correct?") { |q| q.default="y" }
                            if correct == "y"
                                print "Creating account."
                                8.times do
                                   print "." 
                                end
                                create_user(iddin, name, bal.to_f, pin)
                                puts;puts "User created!"
                                sleep 2
                                clear_screen()
                                break
                            else
                                puts "Restarting Creation Process!"
                                sleep 2
                                clear_screen()
                            end
                        elsif user_exist?(iddin)
                            puts "User already exists.\n" 
                        elsif !check_format(iddin)
                            puts "Invalid ID format\n"
                        end
                    end
                when 7
                    clear_screen()
                    puts "List of all users:\n#{retrieve_all().join("\n")}\n"
                end
            end
        else
           puts "Invalid Password" 
           sleep 2
           clear_screen()
        end
    elsif idin == "exit"
        clear_screen()
        break
    elsif !check_format(idin)
        puts "You entered an invalid ID"
        sleep 2
        clear_screen()
    else
        clear_screen()
    end
end
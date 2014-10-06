# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Subscription.create([{name: "Jour", duration: 1, price: 500, ussd_id: 1}, {name: "Semaine", duration: 7, price: 1000, ussd_id: 2}, {name: "Mois", duration: 30, price: 1500, ussd_id: 3}])

QuestionType.create([{name: "Révision scolaire", ussd_id: 1}, {name: "Culture générale", ussd_id: 2}])

AcademicLevel.create([{name: "6ème", question_type_id: 2, ussd_id: 1}, {name: "5ème", question_type_id: 2, ussd_id: 2}, {name: "4ème", question_type_id: 2, ussd_id: 3}, {name: "3ème", question_type_id: 2, ussd_id: 4}, {name: "2nde", question_type_id: 2, ussd_id: 5}, {name: "1ère", question_type_id: 2, ussd_id: 6}, {name: "Tle", question_type_id: 2, ussd_id: 7}])

Parameter.create(outgoing_sms_url: "94.247.177.152:3779", billing_url: "http://10.179.17.75:10010/Air")

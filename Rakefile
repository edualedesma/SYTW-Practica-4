desc "Arrancar el servidor http"
task :default do
  sh "ruby app.rb"
end

desc "Arrancar el servidor via rackup"
task :rackup do
  sh "rackup"
end

# sustituye XXX por el nombre de tu app
desc "Crear app en heroku"
task :create, :appname do |t,args|
  name = args[:appname] || 'XXX';
  sh "heroku create #{name}"
end

desc "Desplegar app en heroku"
task :deploy  do
  sh "git push heroku master"
end

desc "ps"
task :deploy  do
  sh "heroku ps"
end

desc "logs"
task :logs  do
  sh "heroku logs"
end

desc "Destruir despliegue en heroku"
task :logs, :appname  do
  name = args[:appname] || 'XXX';
  sh "heroku apps:destroy #{name}"
end


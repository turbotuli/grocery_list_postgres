require "sinatra"
require "pg"
require "pry"

set :bind, '0.0.0.0'  # bind to all interfaces

configure :development do
  set :db_config, { dbname: "grocery_list_development" }
end

configure :test do
  set :db_config, { dbname: "grocery_list_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get "/" do
  redirect "/groceries"
end

get "/groceries" do
  db_connection do |conn|
    groceries = conn.exec("SELECT groceries.name, groceries.id FROM groceries")
    @groceries = groceries.to_a
  end

  erb :groceries
end

post "/groceries" do
  if params["name"] == ""
    @error = "You must specify an item."

    erb :groceries
  else
    db_connection do |conn|
      conn.exec_params("INSERT INTO groceries (name) VALUES ($1)", [params["name"]])
    end

    redirect "/groceries"
  end

end

get '/groceries/:id' do
  db_connection do |conn|
    item = conn.exec_params("SELECT groceries.name FROM groceries WHERE groceries.id = ($1)",
      [params["id"]])
    @item = item.to_a
  end

  db_connection do |conn|
    comments = conn.exec_params("SELECT groceries.id, comments.body FROM groceries
    JOIN comments ON groceries.id = comments.grocery_id
    WHERE groceries.id = ($1)", [params["id"]])
    @comments = comments.to_a
  end

  erb :item
end

delete '/groceries/:id' do
  db_connection do |conn|
    conn.exec_params("DELETE FROM groceries WHERE id = ($1)", [params["id"]])
  end

  redirect '/groceries'
end

get '/groceries/:id/edit' do
  db_connection do |conn|
    item = conn.exec_params("SELECT groceries.name, groceries.id FROM groceries WHERE groceries.id = ($1)",
      [params["id"]])
    @item = item.to_a
  end

  erb :edit
end

patch '/groceries/:id' do
  if params["item"] == ""
    redirect back
  else
    db_connection do |conn|
      conn.exec_params("UPDATE groceries SET name = ($1) WHERE id = ($2)", [params["item"],params["id"]])
    end

    redirect '/groceries'
  end
end

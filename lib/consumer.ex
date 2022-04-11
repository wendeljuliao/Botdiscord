defmodule Botdiscord.Consumer do

  use Nostrum.Consumer
  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    cond do
      msg.content == "!ping" -> Api.create_message(msg.channel_id, "pong")
      msg.content == "!yeye" -> Api.create_message(msg.channel_id, "glu glu :grin:")
      
      String.starts_with?(msg.content, "!ppt ") -> handlePPTCommand(msg)
      msg.content == "!ppt" -> Api.create_message(msg.channel_id, "Comando para jogar pedra, papel ou tesoura\nUse **!ppt <elemento>**, onde _<elemento>_ deve ser _pedra_, _papel_, ou _tesoura_.")
      
      String.starts_with?(msg.content, "!tempo ") -> handleWeather(msg)
      msg.content == "!tempo" -> Api.create_message(msg.channel_id, "Use **!tempo** <nome-da-cidade>")


      String.starts_with?(msg.content, "!") -> Api.create_message(msg.channel_id, "Comando inválido, tente novamente!")

      true -> :ignore
    end
  end

  def handle_event(_event) do
    :noop
  end

  defp handleWeather(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    cidade = Enum.fetch!(aux, 1)
    
    resp = HTTPoison.get!("https://api.openweathermap.org/data/2.5/weather?q=#{cidade}&appid=#{Application.fetch_env!(:nostrum, :tokenWeather)}&units=metric")
    
    {:ok, map} = Poison.decode(resp.body)

    case map["cod"] do

      200 -> 
        temp = map["main"]["temp"]
        Api.create_message(msg.channel_id, "A temperatura da cidade #{cidade} é de #{temp} °C")
      
      "404" -> 
        Api.create_message(msg.channel_id, "A cidade #{cidade} não foi encontrada. Tente novamente!")


    end

    

  end

  defp handlePPTCommand(msg) do
    aux = String.split(msg.content)
    arg = Enum.fetch!(aux, 1)
    rn = :rand.uniform(3)
    case arg do
      "pedra" -> 
        handleRock(rn, msg)

      "papel" -> 
        handlePaper(rn, msg)

      "tesoura" -> 
        handleScissors(rn, msg)

      _ -> Api.create_message(msg.channel_id, "Argumento inválido!")

    end
  end

  defp handleRock(rn, msg) do
    case rn do
      1 -> Api.create_message(msg.channel_id, "O bot escolheu pedra, houve um empate!")
      2 -> Api.create_message(msg.channel_id, "O bot escolheu papel, o bot ganhou!")
      3 -> Api.create_message(msg.channel_id, "O bot escolheu tesoura, você ganhou!")
    end
  end

  defp handlePaper(rn, msg) do
    case rn do
       1 -> Api.create_message(msg.channel_id, "O bot escolheu pedra, você ganhou!")
          2 -> Api.create_message(msg.channel_id, "O bot escolheu papel, houve um empate!")
          3 -> Api.create_message(msg.channel_id, "O bot escolheu tesoura, o bot ganhou!")
    end
  end

  defp handleScissors(rn, msg) do
    case rn do
      1 -> Api.create_message(msg.channel_id, "O bot escolheu pedra, o bot ganhou!")
      2 -> Api.create_message(msg.channel_id, "O bot escolheu papel, você ganhou!")
      3 -> Api.create_message(msg.channel_id, "O bot escolheu tesoura, houve um empate!")
    end
  end

end
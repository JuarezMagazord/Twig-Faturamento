import React, { useState } from 'react'; // Importa o React e o hook useState do React para gerenciar o estado do componente.
import { useHistory } from 'react-router-dom'; // Importa o hook useHistory do react-router-dom para manipular o histórico de navegação.

const Login = ({ setIsAuthenticated }) => { // Define um componente funcional chamado Login, que recebe a função setIsAuthenticated como prop.
  const [username, setUsername] = useState(''); // Define uma variável de estado chamada username e uma função setUsername para atualizá-la.
  const [password, setPassword] = useState(''); // Define uma variável de estado chamada password e uma função setPassword para atualizá-la.
  const history = useHistory(); // Obtém o objeto history para manipular o histórico de navegação.

  const handleSubmit = (e) => { // Define uma função handleSubmit que será chamada quando o formulário for enviado.
    e.preventDefault(); // Previne o comportamento padrão do formulário de recarregar a página.
    // Lógica de autenticação simulada
    if (username === 'admin' && password === 'password') { // Verifica se as credenciais inseridas são 'admin' e 'password'.
      setIsAuthenticated(true); // Se as credenciais estiverem corretas, chama a função setIsAuthenticated para definir o usuário como autenticado.
      history.push('/dashboard'); // Redireciona o usuário para a página do dashboard.
    } else {
      alert('Credenciais inválidas'); // Se as credenciais estiverem incorretas, exibe um alerta informando credenciais inválidas.
    }
  };

  return (
    <div> // Cria um contêiner div para o formulário de login.
      <h2>Login</h2> // Exibe um título "Login".
      <form onSubmit={handleSubmit}> // Cria um formulário e define a função handleSubmit como o manipulador do evento onSubmit.
        <input
          type="text"
          placeholder="Username"
          value={username}
          onChange={(e) => setUsername(e.target.value)} // Atualiza a variável de estado username quando o usuário digita no campo.
        />
        <input
          type="password"
          placeholder="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)} // Atualiza a variável de estado password quando o usuário digita no campo.
        />
        <button type="submit">Login</button> // Cria um botão de envio para o formulário.
      </form>
    </div>
  );
};

export default Login; // Exporta o componente Login como padrão para que possa ser importado e usado em outros lugares.

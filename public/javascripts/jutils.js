jQuery(function($){
	/* Quando clicar em 2 participantes uma nova tela de 
	 * partida é gerada
	 */
	var oponentes = 0, jogador = new Array(2);
	$('#um_contra_um ul li, .duplas li').click(function(){
		 var $this = $(this), cor; 
		 var nome_jogador = $this.text(), jogador_selecionado = $this.attr('class'), tipo_partida = $this.parent().attr('class'); 
		 
		 //colore os jogadores da partida. 
		 jogador[oponentes] =  nome_jogador;
		 if(oponentes == 0){
		 	cor= 'green';
			oponentes++;
		 }else if(oponentes > 0 && oponentes < 2 ){
		 	cor = 'blue'; 
			oponentes++;
		 }
		 
		 //verifica se o jogador não foi selecionado e marca ele para jogar.
		 if( !(jogador_selecionado == nome_jogador) ){
			$this.css({
		 	 '-webkit-transition': 'background 1s linear',
			 background: cor,
			 color: 'white',
			 'text-shadow': '1px 1px 1px #032260'
		 	});
		 }
		 
		 //se os dois jogadores foram selecionados gera o html para a partida.
		 if(oponentes == 2 ){
			 /* HTML da partida apartir da seleção dos oponentes */
			
			var container = "" || tipo_partida;
			
			 var tpl_partida = '',
			      tpl_p_ini = '<div id="partida">'+
				  			  '<h1><a href="/'+tipo_partida+'">Voltar</a></h1>'+
				  			  '<h2><span class="set">1</span> SET</h2>'+
							  '<p id="tempo"></p>'+
				       		  '<p id="jogo"><span id="'+jogador[0]+'" class="jogador"><span class="maispontos">+</span>'+jogador[0]+'<span class="pontos">0</span><span class="menospontos">-</span></span>'+
							  '<span class="marcador">X</span>'+
							  '<span id="'+jogador[1]+'" class="jogador"><span class="maispontos">+</span><span class="pontos">0</span><span class="menospontos">-</span>'+jogador[1]+'</span></p>'+
							  '<span id="novo_set">novo set</span><span id="fim_partida">acabou</span>',
				  tpl_p_fim = '</div>';
			    
				if(container != 'duplas'){
					$('#um_contra_um').html(tpl_partida + tpl_p_ini +tpl_p_fim).fadeIn('fast');
				     mostraHora('#tempo');
				}else{
					$('#tabela').html(tpl_partida + tpl_p_ini +tpl_p_fim).fadeIn('fast');
					mostraHora('#tempo')
				}
				
				
				/* Clica no botão de terminar a partida 
				 *e envia os dados para o ruby
				 */
				 var sets_jogadorA = [];
				 var sets_jogadorB = [];
				 $('#novo_set, #fim_partida').click(function(){
					 	var $this = $(this), vencedor, jogador = new Array(2);
					 	var bt = $this.attr('id'), pontos = new Array(2), set = $('.set').text(), url_score = $('h1 a').attr('href');
					    
						//jogadores
						jogador[0] =  $('#jogo').find('.jogador:eq(0)').text();
						jogador[1] =  $('#jogo').find('.jogador:eq(1)').text();
						//pontos
						$('.pontos').each(function(i){ pontos[i] = parseInt($(this).text()); });
						
						//verifica o tipo da partida para enviar os dados para a tabela certa.					
						if(url_score == '/'){url_score = '/score_single';}
						else {url_score = '/score_duplas';}

							if( !(pontos[0] == 0 && pontos[1] == 0) && pontos[0] != pontos[1] ){
									if(pontos[0] > pontos[1]){
										vencedor = jogador[0];
										sets_jogadorA.push(1);
										sets_jogadorB.push(0);	
									}else {
										vencedor = jogador[1];
										sets_jogadorA.push(0);
										sets_jogadorB.push(1);	
									}
							 }else {
								alert('Deu empate, em nosso campeonato não existe empate na partida!');
								return false;
							}
							
						if(bt == "fim_partida"){
							var z=0, resultA = 0, resultB = 0;
							
							console.log("Sets: "+sets_jogadorA.length);
							while(z < sets_jogadorA.length){
								
								resultA += sets_jogadorA[z]; 
								resultB += sets_jogadorB[z];
								z++;
							}
							
							if(resultA > resultB){
								vencedor = jogador[0];
							}else {
								vencedor = jogador[1];
							}							
							
							//envia os dados direto para o bd.
							$.ajax({
								url: url_score,
								type: 'POST',
								data: 'set='+set+'&jogador_a='+jogador[0]+'&jogador_b='+jogador[1]+'&vencedor='+vencedor+'&tempo='+$('#tempo').text()+
								      '&pnt_jogador_a='+pontos[0]+'&pnt_jogador_b='+pontos[1]+'&sets_jogadorA='+resultA+'&sets_jogadorB='+resultB,
								success: function(){window.location.href = "/"; sets_jogadorA = sets_jogadorB = 0} //volta para a página index do programa.
							});//fim do ajax
						}else{
							set = parseInt(set)+1;
							$('.pontos').text('0');
							$('.set').text(set);
							horaReset("#tempo");
						    return false;
					   	}//fim dos testes
				   });//fim do evento de clique nos botões "novo set" & "fim_partida"

				 
				/* Atualiza pontuação da partida corrente
				 * Clique no resultado para alterá-lo
				 */
				$('.maispontos, .menospontos').click(function(){
					botao = $(this).attr('class');
					var ponto = (botao == 'menospontos') ? $(this).prev() : $(this).next();
					ponto = parseInt(ponto.text());
					if( $(this).attr('class') == 'menospontos'){
						if(ponto != 0){
							ponto--;
							at_pt = $(this).prev();
                 			at_pt.html(ponto)
						}
					}else{
						ponto++;
						at_pt = $(this).next();
                 		at_pt.html(ponto)
					}
					$(this).children().html(ponto);
				});//fim da função que atualiza a pontução.
				
		 }//fim do teste que monta janela de partida
			 
		return false;
	});//fim da função que gera a tela da partida.

});//fim da jQuery();

/*
 * Funções usadas.
 */
//Relógio HH:MM:SS (atualiza em tempo real)
var hora = minutos = segundos = 0;
function mostraHora(seletor){
		segundos++;
		
		if(segundos > 60){
			minutos++;
			segundos =0;
		} 
		
		if(minutos > 60){
			hora++;
			minutos = 0;
		}
     				
		$(seletor).html(hora+":"+minutos+":"+segundos);
		if(segundos < 10 && minutos < 10)
   		 {
        	$(seletor).html("0" + hora + ":0" + minutos + ":0" + segundos);
    	}
    	else if(segundos > 9 && minutos < 10)
    	{
       		 $(seletor).html("0" + hora + ":0" + minutos + ":" + segundos);
    	}
    	else if(segundos < 10 && minutos > 9)
    	{
			 $(seletor).html("0" + hora + ":" + minutos + ":0" + segundos);
		}
        
		setTimeout(function(){
			mostraHora(seletor);
		}, 1000);
		
}//fim mostraHora()


function horaReset(seletor){
	hora = minutos = segundos = 0;
	$(seletor).html("00:00:00");
}
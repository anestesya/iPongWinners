jQuery(function($){
	
	
	/* Quando clicar em 2 participantes uma nova tela de 
	 * partida é gerada
	 */
	var oponentes = 0, jogador = new Array(2);
	$('#um_contra_um ul li').click(function(){
		 var $this = $(this);
		 var nome_jogador = $this.text(), cor; 
		  
		 jogador[oponentes] =  nome_jogador;
		 console.log(jogador)
		 if(oponentes == 0){
		 	cor= 'green';
			oponentes++;
		 }else if(oponentes > 0 && oponentes < 2 ){
		 	cor = 'blue'; 
			oponentes++; console.log(oponentes)
		 }
		 
		 		 
		 if( !($this.attr('class') == nome_jogador) ){
			$this.css({
		 	 '-webkit-transition': 'background 1s linear',
			 background: cor,
			 color: 'white',
			 'text-shadow': '1px 1px 1px #032260'
		 	});
		 }
		 
		 if(oponentes == 2 ){

			   function mostraHora(){
			 		var tempo = new Date();
			 		var hora, minutos = tempo.getMinutes();
				    if(minutos < 10) {
						minutos = "0"+minutos;
					}
			     	
					$('#tempo').html(tempo.getHours()+":"+minutos+":"+tempo.getSeconds());
					setTimeout(function(){
						mostraHora();
					}, 1000); 
			    }
				
			 /* HTML da partida apartir da seleção dos oponentes */
			 var tpl_partida = '',
			      tpl_p_ini = '<div id="partida">'+
				  			  '<h2>Partida</h2>'+
							  '<p id="tempo"></p>'+
				       		  '<span id="'+jogador[0]+'" class="jogador">'+jogador[0]+' <span class="pontos">0</span></span>'+
							  ' X '+
							  '<span id="'+jogador[1]+'" class="jogador"><span class="pontos">0 </span>'+jogador[1]+'</span>',
				  tpl_p_fim = '</div>';
				  
				
				$('#um_contra_um').html(tpl_partida + tpl_p_ini +tpl_p_fim).fadeIn('fast');
				mostraHora();
				
					
				/* Atualiza pontuação da partida corrente
				 * Clique no resultado para alterá-lo
				 */
				$('.jogador').click(function(){
					var ponto = $(this).children().text();
					ponto = parseInt(ponto);
					ponto++;
					$(this).children().html(ponto);
				});//fim da função que atualiza a pontução.
				
		 }
		 
		 
		return false;
	});//fim da função que gera a tela da partida.

});

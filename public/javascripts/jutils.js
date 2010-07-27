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
				       		  '<p id="jogo"><span id="'+jogador[0]+'" class="jogador">'+jogador[0]+' <span class="pontos">0</span></span>'+
							  '<span class="marcador">X</span>'+
							  '<span id="'+jogador[1]+'" class="jogador"><span class="pontos">0</span>'+jogador[1]+'</span></p>'+
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
				 $('#novo_set, #fim_partida').click(function(){
				 	var pontos = new Array(2), set = $('.set').text();
				    $('.pontos').each(function(i){
					   pontos[i] = parseInt($(this).text());
					});
					
					$.ajax({
						url: '/score_single',
						type: 'POST',
						data: 'set='+set+'&jogador_a='+pontos[0]+'&jogador_b='+pontos[1]+'&tempo='+$('#tempo').text(),
						success: function(){
								set = parseInt(set)+1;
								$('.pontos').text('0');
								$('.set').text(set)
								mostraHora('#tempo');
						}
					});//fim do ajax
					
					if($(this).is('#fim_partida')){
						window.location.href = "/"
						return false;
					}else{
					 	return false;
					}
				 });
				 
				/* Atualiza pontuação da partida corrente
				 * Clique no resultado para alterá-lo
				 */
				$('.jogador').click(function(){
					var ponto = $(this).children().text();
					ponto = parseInt(ponto);
					ponto++;
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
function mostraHora(seletor){
	 		var tempo = new Date();
	 		var hora, minutos = tempo.getMinutes();
		    if(minutos < 10) {
				minutos = "0"+minutos;
			}
	     	
			$(seletor).html(tempo.getHours()+":"+minutos+":"+tempo.getSeconds());
			setTimeout(function(){
				mostraHora("#tempo");
			}, 1000);
}//fim mostraHora()

var timercount = 0;
var timestart  = null;
  
function sw_start(){
	if(!timercount){
	timestart   = new Date();
	document.timeform.timetextarea.value = "00:00";
	document.timeform.laptime.value = "";
	timercount  = setTimeout("mostraHora('#tempo')", 1000);
	}
	else{
	var timeend = new Date();
		var timedifference = timeend.getTime() - timestart.getTime();
		timeend.setTime(timedifference);
		var minutes_passed = timeend.getMinutes();
		if(minutes_passed < 10){
			minutes_passed = "0" + minutes_passed;
		}
		var seconds_passed = timeend.getSeconds();
		if(seconds_passed < 10){
			seconds_passed = "0" + seconds_passed;
		}
		var milliseconds_passed = timeend.getMilliseconds();
		if(milliseconds_passed < 10){
			milliseconds_passed = "00" + milliseconds_passed;
		}
		else if(milliseconds_passed < 100){
			milliseconds_passed = "0" + milliseconds_passed;
		}
		document.timeform.laptime.value = minutes_passed + ":" + seconds_passed + "." + milliseconds_passed;
	}
}
 
function Stop() {
	if(timercount) {
		clearTimeout(timercount);
		timercount  = 0;
		var timeend = new Date();
		var timedifference = timeend.getTime() - timestart.getTime();
		timeend.setTime(timedifference);
		var minutes_passed = timeend.getMinutes();
		if(minutes_passed < 10){
			minutes_passed = "0" + minutes_passed;
		}
		var seconds_passed = timeend.getSeconds();
		if(seconds_passed < 10){
			seconds_passed = "0" + seconds_passed;
		}
		var milliseconds_passed = timeend.getMilliseconds();
		if(milliseconds_passed < 10){
			milliseconds_passed = "00" + milliseconds_passed;
		}
		else if(milliseconds_passed < 100){
			milliseconds_passed = "0" + milliseconds_passed;
		}
		document.timeform.timetextarea.value = minutes_passed + ":" + seconds_passed + "." + milliseconds_passed;
	}
	timestart = null;
}
 
function Reset() {
	timestart = null;
	document.timeform.timetextarea.value = "00:00";
	document.timeform.laptime.value = "";
}
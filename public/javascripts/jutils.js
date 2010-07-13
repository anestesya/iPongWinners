jQuery(function($){
	$('li').click(function(){
		$this = $(this);
		 $this.css({
		 	 '-webkit-transition': 'background 1s linear',
			 background: 'red'
		 });
		return false;
	});
});

jQuery(document).ready(function($) {

    /* ======= Scrollspy ======= */
    $('body').scrollspy({ target: '#header', offset: 400});
    
    /* ======= Fixed header when scrolled ======= */
    
    $(window).bind('scroll', function() {
         if ($(window).scrollTop() > 50) {
             $('#header').addClass('navbar-fixed-top');
         }
         else {
             $('#header').removeClass('navbar-fixed-top');
         }
    });
   
    /* ======= ScrollTo ======= */
    $('a.scrollto').on('click', function(e){
        
        //store hash
        var target = this.hash;
                
        e.preventDefault();
        
		$('body').scrollTo(target, 800, {offset: -70, 'axis':'y', easing:'easeOutQuad'});
        //Collapse mobile menu after clicking
		if ($('.navbar-collapse').hasClass('in')){
			$('.navbar-collapse').removeClass('in').addClass('collapse');
		}
		
	});

  $('.code-example').click(function(e) {
    e.preventDefault();
    $(this).find('i').toggleClass('fa-caret-right fa-caret-down');
    $(this).find('pre').toggleClass('hidden');
  });

  $('span.explainshell').hover(function() {
    console.log(this.text);
    $(this).css('text-decoration', 'underline');
  }, function() {
    $(this).css('text-decoration', 'none');
  });
  $('span.explainshell').click(function() {
    console.log(this.innerHTML);
  });

  hljs.initHighlightingOnLoad();
});
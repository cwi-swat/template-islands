$def menu(x) {
   <ul class="menu" id="someid"> 
   $if (x.hasKids) {
     <li><p>Menu "$x.name;"</p></li>
     $for (k: x.kids) {
       $(menu k)
     }
  }
  $else {
   <li><a href="$x.name;">$x.name;</a></li> 
  }
  </ul>
}
$(menu m)
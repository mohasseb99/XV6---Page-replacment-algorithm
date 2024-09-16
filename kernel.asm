
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc c0 c5 10 80       	mov    $0x8010c5c0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 10 32 10 80       	mov    $0x80103210,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax
80100034:	66 90                	xchg   %ax,%ax
80100036:	66 90                	xchg   %ax,%ax
80100038:	66 90                	xchg   %ax,%ax
8010003a:	66 90                	xchg   %ax,%ax
8010003c:	66 90                	xchg   %ax,%ax
8010003e:	66 90                	xchg   %ax,%ax

80100040 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100040:	55                   	push   %ebp
80100041:	89 e5                	mov    %esp,%ebp
80100043:	57                   	push   %edi
80100044:	89 d7                	mov    %edx,%edi
80100046:	56                   	push   %esi
80100047:	89 c6                	mov    %eax,%esi
80100049:	53                   	push   %ebx
8010004a:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
8010004d:	68 c0 c5 10 80       	push   $0x8010c5c0
80100052:	e8 49 46 00 00       	call   801046a0 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100057:	8b 1d 10 0d 11 80    	mov    0x80110d10,%ebx
8010005d:	83 c4 10             	add    $0x10,%esp
80100060:	81 fb bc 0c 11 80    	cmp    $0x80110cbc,%ebx
80100066:	75 13                	jne    8010007b <bget+0x3b>
80100068:	eb 26                	jmp    80100090 <bget+0x50>
8010006a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80100070:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100073:	81 fb bc 0c 11 80    	cmp    $0x80110cbc,%ebx
80100079:	74 15                	je     80100090 <bget+0x50>
    if(b->dev == dev && b->blockno == blockno){
8010007b:	39 73 04             	cmp    %esi,0x4(%ebx)
8010007e:	75 f0                	jne    80100070 <bget+0x30>
80100080:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100083:	75 eb                	jne    80100070 <bget+0x30>
      b->refcnt++;
80100085:	83 43 4c 01          	addl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
80100089:	eb 3f                	jmp    801000ca <bget+0x8a>
8010008b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010008f:	90                   	nop
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100090:	8b 1d 0c 0d 11 80    	mov    0x80110d0c,%ebx
80100096:	81 fb bc 0c 11 80    	cmp    $0x80110cbc,%ebx
8010009c:	75 0d                	jne    801000ab <bget+0x6b>
8010009e:	eb 4f                	jmp    801000ef <bget+0xaf>
801000a0:	8b 5b 50             	mov    0x50(%ebx),%ebx
801000a3:	81 fb bc 0c 11 80    	cmp    $0x80110cbc,%ebx
801000a9:	74 44                	je     801000ef <bget+0xaf>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
801000ab:	8b 43 4c             	mov    0x4c(%ebx),%eax
801000ae:	85 c0                	test   %eax,%eax
801000b0:	75 ee                	jne    801000a0 <bget+0x60>
801000b2:	f6 03 04             	testb  $0x4,(%ebx)
801000b5:	75 e9                	jne    801000a0 <bget+0x60>
      b->dev = dev;
801000b7:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
801000ba:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000c3:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000ca:	83 ec 0c             	sub    $0xc,%esp
801000cd:	68 c0 c5 10 80       	push   $0x8010c5c0
801000d2:	e8 f9 46 00 00       	call   801047d0 <release>
      acquiresleep(&b->lock);
801000d7:	8d 43 0c             	lea    0xc(%ebx),%eax
801000da:	89 04 24             	mov    %eax,(%esp)
801000dd:	e8 de 43 00 00       	call   801044c0 <acquiresleep>
      return b;
801000e2:	83 c4 10             	add    $0x10,%esp
    }
  }
  panic("bget: no buffers");
}
801000e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e8:	89 d8                	mov    %ebx,%eax
801000ea:	5b                   	pop    %ebx
801000eb:	5e                   	pop    %esi
801000ec:	5f                   	pop    %edi
801000ed:	5d                   	pop    %ebp
801000ee:	c3                   	ret    
  panic("bget: no buffers");
801000ef:	83 ec 0c             	sub    $0xc,%esp
801000f2:	68 40 7a 10 80       	push   $0x80107a40
801000f7:	e8 84 03 00 00       	call   80100480 <panic>
801000fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100100 <binit>:
{
80100100:	f3 0f 1e fb          	endbr32 
80100104:	55                   	push   %ebp
80100105:	89 e5                	mov    %esp,%ebp
80100107:	53                   	push   %ebx
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100108:	bb f4 c5 10 80       	mov    $0x8010c5f4,%ebx
{
8010010d:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
80100110:	68 51 7a 10 80       	push   $0x80107a51
80100115:	68 c0 c5 10 80       	push   $0x8010c5c0
8010011a:	e8 71 44 00 00       	call   80104590 <initlock>
  bcache.head.next = &bcache.head;
8010011f:	83 c4 10             	add    $0x10,%esp
80100122:	b8 bc 0c 11 80       	mov    $0x80110cbc,%eax
  bcache.head.prev = &bcache.head;
80100127:	c7 05 0c 0d 11 80 bc 	movl   $0x80110cbc,0x80110d0c
8010012e:	0c 11 80 
  bcache.head.next = &bcache.head;
80100131:	c7 05 10 0d 11 80 bc 	movl   $0x80110cbc,0x80110d10
80100138:	0c 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010013b:	eb 05                	jmp    80100142 <binit+0x42>
8010013d:	8d 76 00             	lea    0x0(%esi),%esi
80100140:	89 d3                	mov    %edx,%ebx
    b->next = bcache.head.next;
80100142:	89 43 54             	mov    %eax,0x54(%ebx)
    initsleeplock(&b->lock, "buffer");
80100145:	83 ec 08             	sub    $0x8,%esp
80100148:	8d 43 0c             	lea    0xc(%ebx),%eax
    b->prev = &bcache.head;
8010014b:	c7 43 50 bc 0c 11 80 	movl   $0x80110cbc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100152:	68 58 7a 10 80       	push   $0x80107a58
80100157:	50                   	push   %eax
80100158:	e8 23 43 00 00       	call   80104480 <initsleeplock>
    bcache.head.next->prev = b;
8010015d:	a1 10 0d 11 80       	mov    0x80110d10,%eax
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100162:	8d 93 5c 02 00 00    	lea    0x25c(%ebx),%edx
80100168:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
8010016b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010016e:	89 d8                	mov    %ebx,%eax
80100170:	89 1d 10 0d 11 80    	mov    %ebx,0x80110d10
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100176:	81 fb 60 0a 11 80    	cmp    $0x80110a60,%ebx
8010017c:	75 c2                	jne    80100140 <binit+0x40>
}
8010017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100181:	c9                   	leave  
80100182:	c3                   	ret    
80100183:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010018a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100190 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100190:	f3 0f 1e fb          	endbr32 
80100194:	55                   	push   %ebp
80100195:	89 e5                	mov    %esp,%ebp
80100197:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
8010019a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010019d:	8b 45 08             	mov    0x8(%ebp),%eax
801001a0:	e8 9b fe ff ff       	call   80100040 <bget>
  if((b->flags & B_VALID) == 0) {
801001a5:	f6 00 02             	testb  $0x2,(%eax)
801001a8:	74 06                	je     801001b0 <bread+0x20>
    iderw(b);
  }
  return b;
}
801001aa:	c9                   	leave  
801001ab:	c3                   	ret    
801001ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    iderw(b);
801001b0:	83 ec 0c             	sub    $0xc,%esp
801001b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001b6:	50                   	push   %eax
801001b7:	e8 94 22 00 00       	call   80102450 <iderw>
801001bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001bf:	83 c4 10             	add    $0x10,%esp
}
801001c2:	c9                   	leave  
801001c3:	c3                   	ret    
801001c4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801001cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801001cf:	90                   	nop

801001d0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001d0:	f3 0f 1e fb          	endbr32 
801001d4:	55                   	push   %ebp
801001d5:	89 e5                	mov    %esp,%ebp
801001d7:	53                   	push   %ebx
801001d8:	83 ec 10             	sub    $0x10,%esp
801001db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001de:	8d 43 0c             	lea    0xc(%ebx),%eax
801001e1:	50                   	push   %eax
801001e2:	e8 79 43 00 00       	call   80104560 <holdingsleep>
801001e7:	83 c4 10             	add    $0x10,%esp
801001ea:	85 c0                	test   %eax,%eax
801001ec:	74 0f                	je     801001fd <bwrite+0x2d>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001ee:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001f1:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801001f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001f7:	c9                   	leave  
  iderw(b);
801001f8:	e9 53 22 00 00       	jmp    80102450 <iderw>
    panic("bwrite");
801001fd:	83 ec 0c             	sub    $0xc,%esp
80100200:	68 5f 7a 10 80       	push   $0x80107a5f
80100205:	e8 76 02 00 00       	call   80100480 <panic>
8010020a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100210 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100210:	f3 0f 1e fb          	endbr32 
80100214:	55                   	push   %ebp
80100215:	89 e5                	mov    %esp,%ebp
80100217:	56                   	push   %esi
80100218:	53                   	push   %ebx
80100219:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
8010021c:	8d 73 0c             	lea    0xc(%ebx),%esi
8010021f:	83 ec 0c             	sub    $0xc,%esp
80100222:	56                   	push   %esi
80100223:	e8 38 43 00 00       	call   80104560 <holdingsleep>
80100228:	83 c4 10             	add    $0x10,%esp
8010022b:	85 c0                	test   %eax,%eax
8010022d:	74 66                	je     80100295 <brelse+0x85>
    panic("brelse");

  releasesleep(&b->lock);
8010022f:	83 ec 0c             	sub    $0xc,%esp
80100232:	56                   	push   %esi
80100233:	e8 e8 42 00 00       	call   80104520 <releasesleep>

  acquire(&bcache.lock);
80100238:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
8010023f:	e8 5c 44 00 00       	call   801046a0 <acquire>
  b->refcnt--;
80100244:	8b 43 4c             	mov    0x4c(%ebx),%eax
  if (b->refcnt == 0) {
80100247:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
8010024a:	83 e8 01             	sub    $0x1,%eax
8010024d:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
80100250:	85 c0                	test   %eax,%eax
80100252:	75 2f                	jne    80100283 <brelse+0x73>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100254:	8b 43 54             	mov    0x54(%ebx),%eax
80100257:	8b 53 50             	mov    0x50(%ebx),%edx
8010025a:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010025d:	8b 43 50             	mov    0x50(%ebx),%eax
80100260:	8b 53 54             	mov    0x54(%ebx),%edx
80100263:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100266:	a1 10 0d 11 80       	mov    0x80110d10,%eax
    b->prev = &bcache.head;
8010026b:	c7 43 50 bc 0c 11 80 	movl   $0x80110cbc,0x50(%ebx)
    b->next = bcache.head.next;
80100272:	89 43 54             	mov    %eax,0x54(%ebx)
    bcache.head.next->prev = b;
80100275:	a1 10 0d 11 80       	mov    0x80110d10,%eax
8010027a:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010027d:	89 1d 10 0d 11 80    	mov    %ebx,0x80110d10
  }

  release(&bcache.lock);
80100283:	c7 45 08 c0 c5 10 80 	movl   $0x8010c5c0,0x8(%ebp)
}
8010028a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010028d:	5b                   	pop    %ebx
8010028e:	5e                   	pop    %esi
8010028f:	5d                   	pop    %ebp
  release(&bcache.lock);
80100290:	e9 3b 45 00 00       	jmp    801047d0 <release>
    panic("brelse");
80100295:	83 ec 0c             	sub    $0xc,%esp
80100298:	68 66 7a 10 80       	push   $0x80107a66
8010029d:	e8 de 01 00 00       	call   80100480 <panic>
801002a2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801002a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801002b0 <write_page_to_disk>:
{
801002b0:	f3 0f 1e fb          	endbr32 
801002b4:	55                   	push   %ebp
801002b5:	89 e5                	mov    %esp,%ebp
801002b7:	57                   	push   %edi
801002b8:	56                   	push   %esi
801002b9:	53                   	push   %ebx
801002ba:	83 ec 1c             	sub    $0x1c,%esp
801002bd:	8b 7d 10             	mov    0x10(%ebp),%edi
801002c0:	8b 75 0c             	mov    0xc(%ebp),%esi
801002c3:	8d 47 08             	lea    0x8(%edi),%eax
801002c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801002c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    buffer=bget(ROOTDEV,blockno);   // hna howa 3awz ygeeb buffer ally fe blockno low mawgood hrg3 buffer da, low mosh mawgood h3ml wa7d tany w low mawgood hy-override 3la data
801002d0:	89 fa                	mov    %edi,%edx
801002d2:	b8 01 00 00 00       	mov    $0x1,%eax
801002d7:	83 c7 01             	add    $0x1,%edi
801002da:	e8 61 fd ff ff       	call   80100040 <bget>
    memmove(buffer->data,pg+ithPartOfPage,512);   // write 512 bytes to the block
801002df:	83 ec 04             	sub    $0x4,%esp
    buffer=bget(ROOTDEV,blockno);   // hna howa 3awz ygeeb buffer ally fe blockno low mawgood hrg3 buffer da, low mosh mawgood h3ml wa7d tany w low mawgood hy-override 3la data
801002e2:	89 c3                	mov    %eax,%ebx
    memmove(buffer->data,pg+ithPartOfPage,512);   // write 512 bytes to the block
801002e4:	8d 40 5c             	lea    0x5c(%eax),%eax
801002e7:	68 00 02 00 00       	push   $0x200
801002ec:	56                   	push   %esi
801002ed:	81 c6 00 02 00 00    	add    $0x200,%esi
801002f3:	50                   	push   %eax
801002f4:	e8 c7 45 00 00       	call   801048c0 <memmove>
    bwrite(buffer);								  // write buffer to disk and make lock to write
801002f9:	89 1c 24             	mov    %ebx,(%esp)
801002fc:	e8 cf fe ff ff       	call   801001d0 <bwrite>
    brelse(buffer);                               //release lock
80100301:	89 1c 24             	mov    %ebx,(%esp)
80100304:	e8 07 ff ff ff       	call   80100210 <brelse>
  for(int i=0;i<8;i++){
80100309:	83 c4 10             	add    $0x10,%esp
8010030c:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
8010030f:	75 bf                	jne    801002d0 <write_page_to_disk+0x20>
}
80100311:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100314:	5b                   	pop    %ebx
80100315:	5e                   	pop    %esi
80100316:	5f                   	pop    %edi
80100317:	5d                   	pop    %ebp
80100318:	c3                   	ret    
80100319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100320 <read_page_from_disk>:
{
80100320:	f3 0f 1e fb          	endbr32 
80100324:	55                   	push   %ebp
80100325:	89 e5                	mov    %esp,%ebp
80100327:	57                   	push   %edi
80100328:	56                   	push   %esi
80100329:	53                   	push   %ebx
8010032a:	83 ec 1c             	sub    $0x1c,%esp
8010032d:	8b 7d 10             	mov    0x10(%ebp),%edi
80100330:	8b 75 0c             	mov    0xc(%ebp),%esi
80100333:	8d 47 08             	lea    0x8(%edi),%eax
80100336:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    buffer=bread(ROOTDEV,blockno);    //if present in buffer, returns from buffer else from disk  // // Return a locked buf with the contents of the indicated block
80100340:	83 ec 08             	sub    $0x8,%esp
80100343:	57                   	push   %edi
80100344:	83 c7 01             	add    $0x1,%edi
80100347:	6a 01                	push   $0x1
80100349:	e8 42 fe ff ff       	call   80100190 <bread>
    memmove(pg+ithPartOfPage, buffer->data,512);  //write to pg from buffer
8010034e:	83 c4 0c             	add    $0xc,%esp
    buffer=bread(ROOTDEV,blockno);    //if present in buffer, returns from buffer else from disk  // // Return a locked buf with the contents of the indicated block
80100351:	89 c3                	mov    %eax,%ebx
    memmove(pg+ithPartOfPage, buffer->data,512);  //write to pg from buffer
80100353:	8d 40 5c             	lea    0x5c(%eax),%eax
80100356:	68 00 02 00 00       	push   $0x200
8010035b:	50                   	push   %eax
8010035c:	56                   	push   %esi
8010035d:	81 c6 00 02 00 00    	add    $0x200,%esi
80100363:	e8 58 45 00 00       	call   801048c0 <memmove>
    brelse(buffer);                   //release lock
80100368:	89 1c 24             	mov    %ebx,(%esp)
8010036b:	e8 a0 fe ff ff       	call   80100210 <brelse>
  for(int i=0;i<8;i++){
80100370:	83 c4 10             	add    $0x10,%esp
80100373:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80100376:	75 c8                	jne    80100340 <read_page_from_disk+0x20>
}
80100378:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010037b:	5b                   	pop    %ebx
8010037c:	5e                   	pop    %esi
8010037d:	5f                   	pop    %edi
8010037e:	5d                   	pop    %ebp
8010037f:	c3                   	ret    

80100380 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100380:	f3 0f 1e fb          	endbr32 
80100384:	55                   	push   %ebp
80100385:	89 e5                	mov    %esp,%ebp
80100387:	57                   	push   %edi
80100388:	56                   	push   %esi
80100389:	53                   	push   %ebx
8010038a:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
8010038d:	ff 75 08             	pushl  0x8(%ebp)
{
80100390:	8b 5d 10             	mov    0x10(%ebp),%ebx
  target = n;
80100393:	89 de                	mov    %ebx,%esi
  iunlock(ip);
80100395:	e8 86 16 00 00       	call   80101a20 <iunlock>
  acquire(&cons.lock);
8010039a:	c7 04 24 20 b5 10 80 	movl   $0x8010b520,(%esp)
801003a1:	e8 fa 42 00 00       	call   801046a0 <acquire>
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
801003a6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  while(n > 0){
801003a9:	83 c4 10             	add    $0x10,%esp
    *dst++ = c;
801003ac:	01 df                	add    %ebx,%edi
  while(n > 0){
801003ae:	85 db                	test   %ebx,%ebx
801003b0:	0f 8e 97 00 00 00    	jle    8010044d <consoleread+0xcd>
    while(input.r == input.w){
801003b6:	a1 a0 0f 11 80       	mov    0x80110fa0,%eax
801003bb:	3b 05 a4 0f 11 80    	cmp    0x80110fa4,%eax
801003c1:	74 27                	je     801003ea <consoleread+0x6a>
801003c3:	eb 5b                	jmp    80100420 <consoleread+0xa0>
801003c5:	8d 76 00             	lea    0x0(%esi),%esi
      sleep(&input.r, &cons.lock);
801003c8:	83 ec 08             	sub    $0x8,%esp
801003cb:	68 20 b5 10 80       	push   $0x8010b520
801003d0:	68 a0 0f 11 80       	push   $0x80110fa0
801003d5:	e8 f6 3c 00 00       	call   801040d0 <sleep>
    while(input.r == input.w){
801003da:	a1 a0 0f 11 80       	mov    0x80110fa0,%eax
801003df:	83 c4 10             	add    $0x10,%esp
801003e2:	3b 05 a4 0f 11 80    	cmp    0x80110fa4,%eax
801003e8:	75 36                	jne    80100420 <consoleread+0xa0>
      if(myproc()->killed){
801003ea:	e8 51 37 00 00       	call   80103b40 <myproc>
801003ef:	8b 48 24             	mov    0x24(%eax),%ecx
801003f2:	85 c9                	test   %ecx,%ecx
801003f4:	74 d2                	je     801003c8 <consoleread+0x48>
        release(&cons.lock);
801003f6:	83 ec 0c             	sub    $0xc,%esp
801003f9:	68 20 b5 10 80       	push   $0x8010b520
801003fe:	e8 cd 43 00 00       	call   801047d0 <release>
        ilock(ip);
80100403:	5a                   	pop    %edx
80100404:	ff 75 08             	pushl  0x8(%ebp)
80100407:	e8 34 15 00 00       	call   80101940 <ilock>
        return -1;
8010040c:	83 c4 10             	add    $0x10,%esp
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
8010040f:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return -1;
80100412:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100417:	5b                   	pop    %ebx
80100418:	5e                   	pop    %esi
80100419:	5f                   	pop    %edi
8010041a:	5d                   	pop    %ebp
8010041b:	c3                   	ret    
8010041c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = input.buf[input.r++ % INPUT_BUF];
80100420:	8d 50 01             	lea    0x1(%eax),%edx
80100423:	89 15 a0 0f 11 80    	mov    %edx,0x80110fa0
80100429:	89 c2                	mov    %eax,%edx
8010042b:	83 e2 7f             	and    $0x7f,%edx
8010042e:	0f be 8a 20 0f 11 80 	movsbl -0x7feef0e0(%edx),%ecx
    if(c == C('D')){  // EOF
80100435:	80 f9 04             	cmp    $0x4,%cl
80100438:	74 38                	je     80100472 <consoleread+0xf2>
    *dst++ = c;
8010043a:	89 d8                	mov    %ebx,%eax
    --n;
8010043c:	83 eb 01             	sub    $0x1,%ebx
    *dst++ = c;
8010043f:	f7 d8                	neg    %eax
80100441:	88 0c 07             	mov    %cl,(%edi,%eax,1)
    if(c == '\n')
80100444:	83 f9 0a             	cmp    $0xa,%ecx
80100447:	0f 85 61 ff ff ff    	jne    801003ae <consoleread+0x2e>
  release(&cons.lock);
8010044d:	83 ec 0c             	sub    $0xc,%esp
80100450:	68 20 b5 10 80       	push   $0x8010b520
80100455:	e8 76 43 00 00       	call   801047d0 <release>
  ilock(ip);
8010045a:	58                   	pop    %eax
8010045b:	ff 75 08             	pushl  0x8(%ebp)
8010045e:	e8 dd 14 00 00       	call   80101940 <ilock>
  return target - n;
80100463:	89 f0                	mov    %esi,%eax
80100465:	83 c4 10             	add    $0x10,%esp
}
80100468:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return target - n;
8010046b:	29 d8                	sub    %ebx,%eax
}
8010046d:	5b                   	pop    %ebx
8010046e:	5e                   	pop    %esi
8010046f:	5f                   	pop    %edi
80100470:	5d                   	pop    %ebp
80100471:	c3                   	ret    
      if(n < target){
80100472:	39 f3                	cmp    %esi,%ebx
80100474:	73 d7                	jae    8010044d <consoleread+0xcd>
        input.r--;
80100476:	a3 a0 0f 11 80       	mov    %eax,0x80110fa0
8010047b:	eb d0                	jmp    8010044d <consoleread+0xcd>
8010047d:	8d 76 00             	lea    0x0(%esi),%esi

80100480 <panic>:
{
80100480:	f3 0f 1e fb          	endbr32 
80100484:	55                   	push   %ebp
80100485:	89 e5                	mov    %esp,%ebp
80100487:	56                   	push   %esi
80100488:	53                   	push   %ebx
80100489:	83 ec 30             	sub    $0x30,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
8010048c:	fa                   	cli    
  cons.locking = 0;
8010048d:	c7 05 54 b5 10 80 00 	movl   $0x0,0x8010b554
80100494:	00 00 00 
  getcallerpcs(&s, pcs);
80100497:	8d 5d d0             	lea    -0x30(%ebp),%ebx
8010049a:	8d 75 f8             	lea    -0x8(%ebp),%esi
  cprintf("lapicid %d: panic: ", lapicid());
8010049d:	e8 ce 25 00 00       	call   80102a70 <lapicid>
801004a2:	83 ec 08             	sub    $0x8,%esp
801004a5:	50                   	push   %eax
801004a6:	68 6d 7a 10 80       	push   $0x80107a6d
801004ab:	e8 f0 02 00 00       	call   801007a0 <cprintf>
  cprintf(s);
801004b0:	58                   	pop    %eax
801004b1:	ff 75 08             	pushl  0x8(%ebp)
801004b4:	e8 e7 02 00 00       	call   801007a0 <cprintf>
  cprintf("\n");
801004b9:	c7 04 24 94 84 10 80 	movl   $0x80108494,(%esp)
801004c0:	e8 db 02 00 00       	call   801007a0 <cprintf>
  getcallerpcs(&s, pcs);
801004c5:	8d 45 08             	lea    0x8(%ebp),%eax
801004c8:	5a                   	pop    %edx
801004c9:	59                   	pop    %ecx
801004ca:	53                   	push   %ebx
801004cb:	50                   	push   %eax
801004cc:	e8 df 40 00 00       	call   801045b0 <getcallerpcs>
  for(i=0; i<10; i++)
801004d1:	83 c4 10             	add    $0x10,%esp
    cprintf(" %p", pcs[i]);
801004d4:	83 ec 08             	sub    $0x8,%esp
801004d7:	ff 33                	pushl  (%ebx)
801004d9:	83 c3 04             	add    $0x4,%ebx
801004dc:	68 81 7a 10 80       	push   $0x80107a81
801004e1:	e8 ba 02 00 00       	call   801007a0 <cprintf>
  for(i=0; i<10; i++)
801004e6:	83 c4 10             	add    $0x10,%esp
801004e9:	39 f3                	cmp    %esi,%ebx
801004eb:	75 e7                	jne    801004d4 <panic+0x54>
  panicked = 1; // freeze other CPU
801004ed:	c7 05 58 b5 10 80 01 	movl   $0x1,0x8010b558
801004f4:	00 00 00 
  for(;;)
801004f7:	eb fe                	jmp    801004f7 <panic+0x77>
801004f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100500 <consputc.part.0>:
consputc(int c)
80100500:	55                   	push   %ebp
80100501:	89 e5                	mov    %esp,%ebp
80100503:	57                   	push   %edi
80100504:	56                   	push   %esi
80100505:	53                   	push   %ebx
80100506:	89 c3                	mov    %eax,%ebx
80100508:	83 ec 1c             	sub    $0x1c,%esp
  if(c == BACKSPACE){
8010050b:	3d 00 01 00 00       	cmp    $0x100,%eax
80100510:	0f 84 ea 00 00 00    	je     80100600 <consputc.part.0+0x100>
    uartputc(c);
80100516:	83 ec 0c             	sub    $0xc,%esp
80100519:	50                   	push   %eax
8010051a:	e8 a1 5e 00 00       	call   801063c0 <uartputc>
8010051f:	83 c4 10             	add    $0x10,%esp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100522:	bf d4 03 00 00       	mov    $0x3d4,%edi
80100527:	b8 0e 00 00 00       	mov    $0xe,%eax
8010052c:	89 fa                	mov    %edi,%edx
8010052e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010052f:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
80100534:	89 ca                	mov    %ecx,%edx
80100536:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
80100537:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010053a:	89 fa                	mov    %edi,%edx
8010053c:	c1 e0 08             	shl    $0x8,%eax
8010053f:	89 c6                	mov    %eax,%esi
80100541:	b8 0f 00 00 00       	mov    $0xf,%eax
80100546:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100547:	89 ca                	mov    %ecx,%edx
80100549:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
8010054a:	0f b6 c0             	movzbl %al,%eax
8010054d:	09 f0                	or     %esi,%eax
  if(c == '\n')
8010054f:	83 fb 0a             	cmp    $0xa,%ebx
80100552:	0f 84 90 00 00 00    	je     801005e8 <consputc.part.0+0xe8>
  else if(c == BACKSPACE){
80100558:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
8010055e:	74 70                	je     801005d0 <consputc.part.0+0xd0>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100560:	0f b6 db             	movzbl %bl,%ebx
80100563:	8d 70 01             	lea    0x1(%eax),%esi
80100566:	80 cf 07             	or     $0x7,%bh
80100569:	66 89 9c 00 00 80 0b 	mov    %bx,-0x7ff48000(%eax,%eax,1)
80100570:	80 
  if(pos < 0 || pos > 25*80)
80100571:	81 fe d0 07 00 00    	cmp    $0x7d0,%esi
80100577:	0f 8f f9 00 00 00    	jg     80100676 <consputc.part.0+0x176>
  if((pos/80) >= 24){  // Scroll up.
8010057d:	81 fe 7f 07 00 00    	cmp    $0x77f,%esi
80100583:	0f 8f a7 00 00 00    	jg     80100630 <consputc.part.0+0x130>
80100589:	89 f0                	mov    %esi,%eax
8010058b:	8d b4 36 00 80 0b 80 	lea    -0x7ff48000(%esi,%esi,1),%esi
80100592:	88 45 e7             	mov    %al,-0x19(%ebp)
80100595:	0f b6 fc             	movzbl %ah,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100598:	bb d4 03 00 00       	mov    $0x3d4,%ebx
8010059d:	b8 0e 00 00 00       	mov    $0xe,%eax
801005a2:	89 da                	mov    %ebx,%edx
801005a4:	ee                   	out    %al,(%dx)
801005a5:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
801005aa:	89 f8                	mov    %edi,%eax
801005ac:	89 ca                	mov    %ecx,%edx
801005ae:	ee                   	out    %al,(%dx)
801005af:	b8 0f 00 00 00       	mov    $0xf,%eax
801005b4:	89 da                	mov    %ebx,%edx
801005b6:	ee                   	out    %al,(%dx)
801005b7:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
801005bb:	89 ca                	mov    %ecx,%edx
801005bd:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
801005be:	b8 20 07 00 00       	mov    $0x720,%eax
801005c3:	66 89 06             	mov    %ax,(%esi)
}
801005c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801005c9:	5b                   	pop    %ebx
801005ca:	5e                   	pop    %esi
801005cb:	5f                   	pop    %edi
801005cc:	5d                   	pop    %ebp
801005cd:	c3                   	ret    
801005ce:	66 90                	xchg   %ax,%ax
    if(pos > 0) --pos;
801005d0:	8d 70 ff             	lea    -0x1(%eax),%esi
801005d3:	85 c0                	test   %eax,%eax
801005d5:	75 9a                	jne    80100571 <consputc.part.0+0x71>
801005d7:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
801005db:	be 00 80 0b 80       	mov    $0x800b8000,%esi
801005e0:	31 ff                	xor    %edi,%edi
801005e2:	eb b4                	jmp    80100598 <consputc.part.0+0x98>
801005e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    pos += 80 - pos%80;
801005e8:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
801005ed:	f7 e2                	mul    %edx
801005ef:	c1 ea 06             	shr    $0x6,%edx
801005f2:	8d 04 92             	lea    (%edx,%edx,4),%eax
801005f5:	c1 e0 04             	shl    $0x4,%eax
801005f8:	8d 70 50             	lea    0x50(%eax),%esi
801005fb:	e9 71 ff ff ff       	jmp    80100571 <consputc.part.0+0x71>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100600:	83 ec 0c             	sub    $0xc,%esp
80100603:	6a 08                	push   $0x8
80100605:	e8 b6 5d 00 00       	call   801063c0 <uartputc>
8010060a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100611:	e8 aa 5d 00 00       	call   801063c0 <uartputc>
80100616:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010061d:	e8 9e 5d 00 00       	call   801063c0 <uartputc>
80100622:	83 c4 10             	add    $0x10,%esp
80100625:	e9 f8 fe ff ff       	jmp    80100522 <consputc.part.0+0x22>
8010062a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100630:	83 ec 04             	sub    $0x4,%esp
    pos -= 80;
80100633:	8d 5e b0             	lea    -0x50(%esi),%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100636:	8d b4 36 60 7f 0b 80 	lea    -0x7ff480a0(%esi,%esi,1),%esi
8010063d:	bf 07 00 00 00       	mov    $0x7,%edi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100642:	68 60 0e 00 00       	push   $0xe60
80100647:	68 a0 80 0b 80       	push   $0x800b80a0
8010064c:	68 00 80 0b 80       	push   $0x800b8000
80100651:	e8 6a 42 00 00       	call   801048c0 <memmove>
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100656:	b8 80 07 00 00       	mov    $0x780,%eax
8010065b:	83 c4 0c             	add    $0xc,%esp
8010065e:	29 d8                	sub    %ebx,%eax
80100660:	01 c0                	add    %eax,%eax
80100662:	50                   	push   %eax
80100663:	6a 00                	push   $0x0
80100665:	56                   	push   %esi
80100666:	e8 b5 41 00 00       	call   80104820 <memset>
8010066b:	88 5d e7             	mov    %bl,-0x19(%ebp)
8010066e:	83 c4 10             	add    $0x10,%esp
80100671:	e9 22 ff ff ff       	jmp    80100598 <consputc.part.0+0x98>
    panic("pos under/overflow");
80100676:	83 ec 0c             	sub    $0xc,%esp
80100679:	68 85 7a 10 80       	push   $0x80107a85
8010067e:	e8 fd fd ff ff       	call   80100480 <panic>
80100683:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010068a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100690 <printint>:
{
80100690:	55                   	push   %ebp
80100691:	89 e5                	mov    %esp,%ebp
80100693:	57                   	push   %edi
80100694:	56                   	push   %esi
80100695:	53                   	push   %ebx
80100696:	83 ec 2c             	sub    $0x2c,%esp
80100699:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  if(sign && (sign = xx < 0))
8010069c:	85 c9                	test   %ecx,%ecx
8010069e:	74 04                	je     801006a4 <printint+0x14>
801006a0:	85 c0                	test   %eax,%eax
801006a2:	78 6d                	js     80100711 <printint+0x81>
    x = xx;
801006a4:	89 c1                	mov    %eax,%ecx
801006a6:	31 f6                	xor    %esi,%esi
  i = 0;
801006a8:	89 75 cc             	mov    %esi,-0x34(%ebp)
801006ab:	31 db                	xor    %ebx,%ebx
801006ad:	8d 7d d7             	lea    -0x29(%ebp),%edi
    buf[i++] = digits[x % base];
801006b0:	89 c8                	mov    %ecx,%eax
801006b2:	31 d2                	xor    %edx,%edx
801006b4:	89 ce                	mov    %ecx,%esi
801006b6:	f7 75 d4             	divl   -0x2c(%ebp)
801006b9:	0f b6 92 b0 7a 10 80 	movzbl -0x7fef8550(%edx),%edx
801006c0:	89 45 d0             	mov    %eax,-0x30(%ebp)
801006c3:	89 d8                	mov    %ebx,%eax
801006c5:	8d 5b 01             	lea    0x1(%ebx),%ebx
  }while((x /= base) != 0);
801006c8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
801006cb:	89 75 d0             	mov    %esi,-0x30(%ebp)
    buf[i++] = digits[x % base];
801006ce:	88 14 1f             	mov    %dl,(%edi,%ebx,1)
  }while((x /= base) != 0);
801006d1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
801006d4:	39 75 d0             	cmp    %esi,-0x30(%ebp)
801006d7:	73 d7                	jae    801006b0 <printint+0x20>
801006d9:	8b 75 cc             	mov    -0x34(%ebp),%esi
  if(sign)
801006dc:	85 f6                	test   %esi,%esi
801006de:	74 0c                	je     801006ec <printint+0x5c>
    buf[i++] = '-';
801006e0:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
    buf[i++] = digits[x % base];
801006e5:	89 d8                	mov    %ebx,%eax
    buf[i++] = '-';
801006e7:	ba 2d 00 00 00       	mov    $0x2d,%edx
  while(--i >= 0)
801006ec:	8d 5c 05 d7          	lea    -0x29(%ebp,%eax,1),%ebx
801006f0:	0f be c2             	movsbl %dl,%eax
  if(panicked){
801006f3:	8b 15 58 b5 10 80    	mov    0x8010b558,%edx
801006f9:	85 d2                	test   %edx,%edx
801006fb:	74 03                	je     80100700 <printint+0x70>
  asm volatile("cli");
801006fd:	fa                   	cli    
    for(;;)
801006fe:	eb fe                	jmp    801006fe <printint+0x6e>
80100700:	e8 fb fd ff ff       	call   80100500 <consputc.part.0>
  while(--i >= 0)
80100705:	39 fb                	cmp    %edi,%ebx
80100707:	74 10                	je     80100719 <printint+0x89>
80100709:	0f be 03             	movsbl (%ebx),%eax
8010070c:	83 eb 01             	sub    $0x1,%ebx
8010070f:	eb e2                	jmp    801006f3 <printint+0x63>
    x = -xx;
80100711:	f7 d8                	neg    %eax
80100713:	89 ce                	mov    %ecx,%esi
80100715:	89 c1                	mov    %eax,%ecx
80100717:	eb 8f                	jmp    801006a8 <printint+0x18>
}
80100719:	83 c4 2c             	add    $0x2c,%esp
8010071c:	5b                   	pop    %ebx
8010071d:	5e                   	pop    %esi
8010071e:	5f                   	pop    %edi
8010071f:	5d                   	pop    %ebp
80100720:	c3                   	ret    
80100721:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100728:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010072f:	90                   	nop

80100730 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100730:	f3 0f 1e fb          	endbr32 
80100734:	55                   	push   %ebp
80100735:	89 e5                	mov    %esp,%ebp
80100737:	57                   	push   %edi
80100738:	56                   	push   %esi
80100739:	53                   	push   %ebx
8010073a:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
8010073d:	ff 75 08             	pushl  0x8(%ebp)
{
80100740:	8b 5d 10             	mov    0x10(%ebp),%ebx
  iunlock(ip);
80100743:	e8 d8 12 00 00       	call   80101a20 <iunlock>
  acquire(&cons.lock);
80100748:	c7 04 24 20 b5 10 80 	movl   $0x8010b520,(%esp)
8010074f:	e8 4c 3f 00 00       	call   801046a0 <acquire>
  for(i = 0; i < n; i++)
80100754:	83 c4 10             	add    $0x10,%esp
80100757:	85 db                	test   %ebx,%ebx
80100759:	7e 24                	jle    8010077f <consolewrite+0x4f>
8010075b:	8b 7d 0c             	mov    0xc(%ebp),%edi
8010075e:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
  if(panicked){
80100761:	8b 15 58 b5 10 80    	mov    0x8010b558,%edx
80100767:	85 d2                	test   %edx,%edx
80100769:	74 05                	je     80100770 <consolewrite+0x40>
8010076b:	fa                   	cli    
    for(;;)
8010076c:	eb fe                	jmp    8010076c <consolewrite+0x3c>
8010076e:	66 90                	xchg   %ax,%ax
    consputc(buf[i] & 0xff);
80100770:	0f b6 07             	movzbl (%edi),%eax
80100773:	83 c7 01             	add    $0x1,%edi
80100776:	e8 85 fd ff ff       	call   80100500 <consputc.part.0>
  for(i = 0; i < n; i++)
8010077b:	39 fe                	cmp    %edi,%esi
8010077d:	75 e2                	jne    80100761 <consolewrite+0x31>
  release(&cons.lock);
8010077f:	83 ec 0c             	sub    $0xc,%esp
80100782:	68 20 b5 10 80       	push   $0x8010b520
80100787:	e8 44 40 00 00       	call   801047d0 <release>
  ilock(ip);
8010078c:	58                   	pop    %eax
8010078d:	ff 75 08             	pushl  0x8(%ebp)
80100790:	e8 ab 11 00 00       	call   80101940 <ilock>

  return n;
}
80100795:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100798:	89 d8                	mov    %ebx,%eax
8010079a:	5b                   	pop    %ebx
8010079b:	5e                   	pop    %esi
8010079c:	5f                   	pop    %edi
8010079d:	5d                   	pop    %ebp
8010079e:	c3                   	ret    
8010079f:	90                   	nop

801007a0 <cprintf>:
{
801007a0:	f3 0f 1e fb          	endbr32 
801007a4:	55                   	push   %ebp
801007a5:	89 e5                	mov    %esp,%ebp
801007a7:	57                   	push   %edi
801007a8:	56                   	push   %esi
801007a9:	53                   	push   %ebx
801007aa:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
801007ad:	a1 54 b5 10 80       	mov    0x8010b554,%eax
801007b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(locking)
801007b5:	85 c0                	test   %eax,%eax
801007b7:	0f 85 e8 00 00 00    	jne    801008a5 <cprintf+0x105>
  if (fmt == 0)
801007bd:	8b 45 08             	mov    0x8(%ebp),%eax
801007c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801007c3:	85 c0                	test   %eax,%eax
801007c5:	0f 84 5a 01 00 00    	je     80100925 <cprintf+0x185>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801007cb:	0f b6 00             	movzbl (%eax),%eax
801007ce:	85 c0                	test   %eax,%eax
801007d0:	74 36                	je     80100808 <cprintf+0x68>
  argp = (uint*)(void*)(&fmt + 1);
801007d2:	8d 5d 0c             	lea    0xc(%ebp),%ebx
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801007d5:	31 f6                	xor    %esi,%esi
    if(c != '%'){
801007d7:	83 f8 25             	cmp    $0x25,%eax
801007da:	74 44                	je     80100820 <cprintf+0x80>
  if(panicked){
801007dc:	8b 0d 58 b5 10 80    	mov    0x8010b558,%ecx
801007e2:	85 c9                	test   %ecx,%ecx
801007e4:	74 0f                	je     801007f5 <cprintf+0x55>
801007e6:	fa                   	cli    
    for(;;)
801007e7:	eb fe                	jmp    801007e7 <cprintf+0x47>
801007e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801007f0:	b8 25 00 00 00       	mov    $0x25,%eax
801007f5:	e8 06 fd ff ff       	call   80100500 <consputc.part.0>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801007fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801007fd:	83 c6 01             	add    $0x1,%esi
80100800:	0f b6 04 30          	movzbl (%eax,%esi,1),%eax
80100804:	85 c0                	test   %eax,%eax
80100806:	75 cf                	jne    801007d7 <cprintf+0x37>
  if(locking)
80100808:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010080b:	85 c0                	test   %eax,%eax
8010080d:	0f 85 fd 00 00 00    	jne    80100910 <cprintf+0x170>
}
80100813:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100816:	5b                   	pop    %ebx
80100817:	5e                   	pop    %esi
80100818:	5f                   	pop    %edi
80100819:	5d                   	pop    %ebp
8010081a:	c3                   	ret    
8010081b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010081f:	90                   	nop
    c = fmt[++i] & 0xff;
80100820:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100823:	83 c6 01             	add    $0x1,%esi
80100826:	0f b6 3c 30          	movzbl (%eax,%esi,1),%edi
    if(c == 0)
8010082a:	85 ff                	test   %edi,%edi
8010082c:	74 da                	je     80100808 <cprintf+0x68>
    switch(c){
8010082e:	83 ff 70             	cmp    $0x70,%edi
80100831:	74 5a                	je     8010088d <cprintf+0xed>
80100833:	7f 2a                	jg     8010085f <cprintf+0xbf>
80100835:	83 ff 25             	cmp    $0x25,%edi
80100838:	0f 84 92 00 00 00    	je     801008d0 <cprintf+0x130>
8010083e:	83 ff 64             	cmp    $0x64,%edi
80100841:	0f 85 a1 00 00 00    	jne    801008e8 <cprintf+0x148>
      printint(*argp++, 10, 1);
80100847:	8b 03                	mov    (%ebx),%eax
80100849:	8d 7b 04             	lea    0x4(%ebx),%edi
8010084c:	b9 01 00 00 00       	mov    $0x1,%ecx
80100851:	ba 0a 00 00 00       	mov    $0xa,%edx
80100856:	89 fb                	mov    %edi,%ebx
80100858:	e8 33 fe ff ff       	call   80100690 <printint>
      break;
8010085d:	eb 9b                	jmp    801007fa <cprintf+0x5a>
    switch(c){
8010085f:	83 ff 73             	cmp    $0x73,%edi
80100862:	75 24                	jne    80100888 <cprintf+0xe8>
      if((s = (char*)*argp++) == 0)
80100864:	8d 7b 04             	lea    0x4(%ebx),%edi
80100867:	8b 1b                	mov    (%ebx),%ebx
80100869:	85 db                	test   %ebx,%ebx
8010086b:	75 55                	jne    801008c2 <cprintf+0x122>
        s = "(null)";
8010086d:	bb 98 7a 10 80       	mov    $0x80107a98,%ebx
      for(; *s; s++)
80100872:	b8 28 00 00 00       	mov    $0x28,%eax
  if(panicked){
80100877:	8b 15 58 b5 10 80    	mov    0x8010b558,%edx
8010087d:	85 d2                	test   %edx,%edx
8010087f:	74 39                	je     801008ba <cprintf+0x11a>
80100881:	fa                   	cli    
    for(;;)
80100882:	eb fe                	jmp    80100882 <cprintf+0xe2>
80100884:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    switch(c){
80100888:	83 ff 78             	cmp    $0x78,%edi
8010088b:	75 5b                	jne    801008e8 <cprintf+0x148>
      printint(*argp++, 16, 0);
8010088d:	8b 03                	mov    (%ebx),%eax
8010088f:	8d 7b 04             	lea    0x4(%ebx),%edi
80100892:	31 c9                	xor    %ecx,%ecx
80100894:	ba 10 00 00 00       	mov    $0x10,%edx
80100899:	89 fb                	mov    %edi,%ebx
8010089b:	e8 f0 fd ff ff       	call   80100690 <printint>
      break;
801008a0:	e9 55 ff ff ff       	jmp    801007fa <cprintf+0x5a>
    acquire(&cons.lock);
801008a5:	83 ec 0c             	sub    $0xc,%esp
801008a8:	68 20 b5 10 80       	push   $0x8010b520
801008ad:	e8 ee 3d 00 00       	call   801046a0 <acquire>
801008b2:	83 c4 10             	add    $0x10,%esp
801008b5:	e9 03 ff ff ff       	jmp    801007bd <cprintf+0x1d>
801008ba:	e8 41 fc ff ff       	call   80100500 <consputc.part.0>
      for(; *s; s++)
801008bf:	83 c3 01             	add    $0x1,%ebx
801008c2:	0f be 03             	movsbl (%ebx),%eax
801008c5:	84 c0                	test   %al,%al
801008c7:	75 ae                	jne    80100877 <cprintf+0xd7>
      if((s = (char*)*argp++) == 0)
801008c9:	89 fb                	mov    %edi,%ebx
801008cb:	e9 2a ff ff ff       	jmp    801007fa <cprintf+0x5a>
  if(panicked){
801008d0:	8b 3d 58 b5 10 80    	mov    0x8010b558,%edi
801008d6:	85 ff                	test   %edi,%edi
801008d8:	0f 84 12 ff ff ff    	je     801007f0 <cprintf+0x50>
801008de:	fa                   	cli    
    for(;;)
801008df:	eb fe                	jmp    801008df <cprintf+0x13f>
801008e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(panicked){
801008e8:	8b 0d 58 b5 10 80    	mov    0x8010b558,%ecx
801008ee:	85 c9                	test   %ecx,%ecx
801008f0:	74 06                	je     801008f8 <cprintf+0x158>
801008f2:	fa                   	cli    
    for(;;)
801008f3:	eb fe                	jmp    801008f3 <cprintf+0x153>
801008f5:	8d 76 00             	lea    0x0(%esi),%esi
801008f8:	b8 25 00 00 00       	mov    $0x25,%eax
801008fd:	e8 fe fb ff ff       	call   80100500 <consputc.part.0>
  if(panicked){
80100902:	8b 15 58 b5 10 80    	mov    0x8010b558,%edx
80100908:	85 d2                	test   %edx,%edx
8010090a:	74 2c                	je     80100938 <cprintf+0x198>
8010090c:	fa                   	cli    
    for(;;)
8010090d:	eb fe                	jmp    8010090d <cprintf+0x16d>
8010090f:	90                   	nop
    release(&cons.lock);
80100910:	83 ec 0c             	sub    $0xc,%esp
80100913:	68 20 b5 10 80       	push   $0x8010b520
80100918:	e8 b3 3e 00 00       	call   801047d0 <release>
8010091d:	83 c4 10             	add    $0x10,%esp
}
80100920:	e9 ee fe ff ff       	jmp    80100813 <cprintf+0x73>
    panic("null fmt");
80100925:	83 ec 0c             	sub    $0xc,%esp
80100928:	68 9f 7a 10 80       	push   $0x80107a9f
8010092d:	e8 4e fb ff ff       	call   80100480 <panic>
80100932:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80100938:	89 f8                	mov    %edi,%eax
8010093a:	e8 c1 fb ff ff       	call   80100500 <consputc.part.0>
8010093f:	e9 b6 fe ff ff       	jmp    801007fa <cprintf+0x5a>
80100944:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010094b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010094f:	90                   	nop

80100950 <consoleintr>:
{
80100950:	f3 0f 1e fb          	endbr32 
80100954:	55                   	push   %ebp
80100955:	89 e5                	mov    %esp,%ebp
80100957:	57                   	push   %edi
80100958:	56                   	push   %esi
  int c, doprocdump = 0;
80100959:	31 f6                	xor    %esi,%esi
{
8010095b:	53                   	push   %ebx
8010095c:	83 ec 18             	sub    $0x18,%esp
8010095f:	8b 7d 08             	mov    0x8(%ebp),%edi
  acquire(&cons.lock);
80100962:	68 20 b5 10 80       	push   $0x8010b520
80100967:	e8 34 3d 00 00       	call   801046a0 <acquire>
  while((c = getc()) >= 0){
8010096c:	83 c4 10             	add    $0x10,%esp
8010096f:	eb 17                	jmp    80100988 <consoleintr+0x38>
    switch(c){
80100971:	83 fb 08             	cmp    $0x8,%ebx
80100974:	0f 84 f6 00 00 00    	je     80100a70 <consoleintr+0x120>
8010097a:	83 fb 10             	cmp    $0x10,%ebx
8010097d:	0f 85 15 01 00 00    	jne    80100a98 <consoleintr+0x148>
80100983:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
80100988:	ff d7                	call   *%edi
8010098a:	89 c3                	mov    %eax,%ebx
8010098c:	85 c0                	test   %eax,%eax
8010098e:	0f 88 23 01 00 00    	js     80100ab7 <consoleintr+0x167>
    switch(c){
80100994:	83 fb 15             	cmp    $0x15,%ebx
80100997:	74 77                	je     80100a10 <consoleintr+0xc0>
80100999:	7e d6                	jle    80100971 <consoleintr+0x21>
8010099b:	83 fb 7f             	cmp    $0x7f,%ebx
8010099e:	0f 84 cc 00 00 00    	je     80100a70 <consoleintr+0x120>
      if(c != 0 && input.e-input.r < INPUT_BUF){
801009a4:	a1 a8 0f 11 80       	mov    0x80110fa8,%eax
801009a9:	89 c2                	mov    %eax,%edx
801009ab:	2b 15 a0 0f 11 80    	sub    0x80110fa0,%edx
801009b1:	83 fa 7f             	cmp    $0x7f,%edx
801009b4:	77 d2                	ja     80100988 <consoleintr+0x38>
        c = (c == '\r') ? '\n' : c;
801009b6:	8d 48 01             	lea    0x1(%eax),%ecx
801009b9:	8b 15 58 b5 10 80    	mov    0x8010b558,%edx
801009bf:	83 e0 7f             	and    $0x7f,%eax
        input.buf[input.e++ % INPUT_BUF] = c;
801009c2:	89 0d a8 0f 11 80    	mov    %ecx,0x80110fa8
        c = (c == '\r') ? '\n' : c;
801009c8:	83 fb 0d             	cmp    $0xd,%ebx
801009cb:	0f 84 02 01 00 00    	je     80100ad3 <consoleintr+0x183>
        input.buf[input.e++ % INPUT_BUF] = c;
801009d1:	88 98 20 0f 11 80    	mov    %bl,-0x7feef0e0(%eax)
  if(panicked){
801009d7:	85 d2                	test   %edx,%edx
801009d9:	0f 85 ff 00 00 00    	jne    80100ade <consoleintr+0x18e>
801009df:	89 d8                	mov    %ebx,%eax
801009e1:	e8 1a fb ff ff       	call   80100500 <consputc.part.0>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009e6:	83 fb 0a             	cmp    $0xa,%ebx
801009e9:	0f 84 0f 01 00 00    	je     80100afe <consoleintr+0x1ae>
801009ef:	83 fb 04             	cmp    $0x4,%ebx
801009f2:	0f 84 06 01 00 00    	je     80100afe <consoleintr+0x1ae>
801009f8:	a1 a0 0f 11 80       	mov    0x80110fa0,%eax
801009fd:	83 e8 80             	sub    $0xffffff80,%eax
80100a00:	39 05 a8 0f 11 80    	cmp    %eax,0x80110fa8
80100a06:	75 80                	jne    80100988 <consoleintr+0x38>
80100a08:	e9 f6 00 00 00       	jmp    80100b03 <consoleintr+0x1b3>
80100a0d:	8d 76 00             	lea    0x0(%esi),%esi
      while(input.e != input.w &&
80100a10:	a1 a8 0f 11 80       	mov    0x80110fa8,%eax
80100a15:	39 05 a4 0f 11 80    	cmp    %eax,0x80110fa4
80100a1b:	0f 84 67 ff ff ff    	je     80100988 <consoleintr+0x38>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100a21:	83 e8 01             	sub    $0x1,%eax
80100a24:	89 c2                	mov    %eax,%edx
80100a26:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
80100a29:	80 ba 20 0f 11 80 0a 	cmpb   $0xa,-0x7feef0e0(%edx)
80100a30:	0f 84 52 ff ff ff    	je     80100988 <consoleintr+0x38>
  if(panicked){
80100a36:	8b 15 58 b5 10 80    	mov    0x8010b558,%edx
        input.e--;
80100a3c:	a3 a8 0f 11 80       	mov    %eax,0x80110fa8
  if(panicked){
80100a41:	85 d2                	test   %edx,%edx
80100a43:	74 0b                	je     80100a50 <consoleintr+0x100>
80100a45:	fa                   	cli    
    for(;;)
80100a46:	eb fe                	jmp    80100a46 <consoleintr+0xf6>
80100a48:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100a4f:	90                   	nop
80100a50:	b8 00 01 00 00       	mov    $0x100,%eax
80100a55:	e8 a6 fa ff ff       	call   80100500 <consputc.part.0>
      while(input.e != input.w &&
80100a5a:	a1 a8 0f 11 80       	mov    0x80110fa8,%eax
80100a5f:	3b 05 a4 0f 11 80    	cmp    0x80110fa4,%eax
80100a65:	75 ba                	jne    80100a21 <consoleintr+0xd1>
80100a67:	e9 1c ff ff ff       	jmp    80100988 <consoleintr+0x38>
80100a6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      if(input.e != input.w){
80100a70:	a1 a8 0f 11 80       	mov    0x80110fa8,%eax
80100a75:	3b 05 a4 0f 11 80    	cmp    0x80110fa4,%eax
80100a7b:	0f 84 07 ff ff ff    	je     80100988 <consoleintr+0x38>
        input.e--;
80100a81:	83 e8 01             	sub    $0x1,%eax
80100a84:	a3 a8 0f 11 80       	mov    %eax,0x80110fa8
  if(panicked){
80100a89:	a1 58 b5 10 80       	mov    0x8010b558,%eax
80100a8e:	85 c0                	test   %eax,%eax
80100a90:	74 16                	je     80100aa8 <consoleintr+0x158>
80100a92:	fa                   	cli    
    for(;;)
80100a93:	eb fe                	jmp    80100a93 <consoleintr+0x143>
80100a95:	8d 76 00             	lea    0x0(%esi),%esi
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100a98:	85 db                	test   %ebx,%ebx
80100a9a:	0f 84 e8 fe ff ff    	je     80100988 <consoleintr+0x38>
80100aa0:	e9 ff fe ff ff       	jmp    801009a4 <consoleintr+0x54>
80100aa5:	8d 76 00             	lea    0x0(%esi),%esi
80100aa8:	b8 00 01 00 00       	mov    $0x100,%eax
80100aad:	e8 4e fa ff ff       	call   80100500 <consputc.part.0>
80100ab2:	e9 d1 fe ff ff       	jmp    80100988 <consoleintr+0x38>
  release(&cons.lock);
80100ab7:	83 ec 0c             	sub    $0xc,%esp
80100aba:	68 20 b5 10 80       	push   $0x8010b520
80100abf:	e8 0c 3d 00 00       	call   801047d0 <release>
  if(doprocdump) {
80100ac4:	83 c4 10             	add    $0x10,%esp
80100ac7:	85 f6                	test   %esi,%esi
80100ac9:	75 1d                	jne    80100ae8 <consoleintr+0x198>
}
80100acb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100ace:	5b                   	pop    %ebx
80100acf:	5e                   	pop    %esi
80100ad0:	5f                   	pop    %edi
80100ad1:	5d                   	pop    %ebp
80100ad2:	c3                   	ret    
        input.buf[input.e++ % INPUT_BUF] = c;
80100ad3:	c6 80 20 0f 11 80 0a 	movb   $0xa,-0x7feef0e0(%eax)
  if(panicked){
80100ada:	85 d2                	test   %edx,%edx
80100adc:	74 16                	je     80100af4 <consoleintr+0x1a4>
80100ade:	fa                   	cli    
    for(;;)
80100adf:	eb fe                	jmp    80100adf <consoleintr+0x18f>
80100ae1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
}
80100ae8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100aeb:	5b                   	pop    %ebx
80100aec:	5e                   	pop    %esi
80100aed:	5f                   	pop    %edi
80100aee:	5d                   	pop    %ebp
    procdump();  // now call procdump() wo. cons.lock held
80100aef:	e9 ac 38 00 00       	jmp    801043a0 <procdump>
80100af4:	b8 0a 00 00 00       	mov    $0xa,%eax
80100af9:	e8 02 fa ff ff       	call   80100500 <consputc.part.0>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100afe:	a1 a8 0f 11 80       	mov    0x80110fa8,%eax
          wakeup(&input.r);
80100b03:	83 ec 0c             	sub    $0xc,%esp
          input.w = input.e;
80100b06:	a3 a4 0f 11 80       	mov    %eax,0x80110fa4
          wakeup(&input.r);
80100b0b:	68 a0 0f 11 80       	push   $0x80110fa0
80100b10:	e8 8b 37 00 00       	call   801042a0 <wakeup>
80100b15:	83 c4 10             	add    $0x10,%esp
80100b18:	e9 6b fe ff ff       	jmp    80100988 <consoleintr+0x38>
80100b1d:	8d 76 00             	lea    0x0(%esi),%esi

80100b20 <consoleinit>:

void
consoleinit(void)
{
80100b20:	f3 0f 1e fb          	endbr32 
80100b24:	55                   	push   %ebp
80100b25:	89 e5                	mov    %esp,%ebp
80100b27:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100b2a:	68 a8 7a 10 80       	push   $0x80107aa8
80100b2f:	68 20 b5 10 80       	push   $0x8010b520
80100b34:	e8 57 3a 00 00       	call   80104590 <initlock>

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  ioapicenable(IRQ_KBD, 0);
80100b39:	58                   	pop    %eax
80100b3a:	5a                   	pop    %edx
80100b3b:	6a 00                	push   $0x0
80100b3d:	6a 01                	push   $0x1
  devsw[CONSOLE].write = consolewrite;
80100b3f:	c7 05 6c 19 11 80 30 	movl   $0x80100730,0x8011196c
80100b46:	07 10 80 
  devsw[CONSOLE].read = consoleread;
80100b49:	c7 05 68 19 11 80 80 	movl   $0x80100380,0x80111968
80100b50:	03 10 80 
  cons.locking = 1;
80100b53:	c7 05 54 b5 10 80 01 	movl   $0x1,0x8010b554
80100b5a:	00 00 00 
  ioapicenable(IRQ_KBD, 0);
80100b5d:	e8 9e 1a 00 00       	call   80102600 <ioapicenable>
}
80100b62:	83 c4 10             	add    $0x10,%esp
80100b65:	c9                   	leave  
80100b66:	c3                   	ret    
80100b67:	66 90                	xchg   %ax,%ax
80100b69:	66 90                	xchg   %ax,%ax
80100b6b:	66 90                	xchg   %ax,%ax
80100b6d:	66 90                	xchg   %ax,%ax
80100b6f:	90                   	nop

80100b70 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b70:	f3 0f 1e fb          	endbr32 
80100b74:	55                   	push   %ebp
80100b75:	89 e5                	mov    %esp,%ebp
80100b77:	57                   	push   %edi
80100b78:	56                   	push   %esi
80100b79:	53                   	push   %ebx
80100b7a:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b80:	e8 bb 2f 00 00       	call   80103b40 <myproc>
80100b85:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
80100b8b:	e8 70 23 00 00       	call   80102f00 <begin_op>

  if((ip = namei(path)) == 0){
80100b90:	83 ec 0c             	sub    $0xc,%esp
80100b93:	ff 75 08             	pushl  0x8(%ebp)
80100b96:	e8 75 16 00 00       	call   80102210 <namei>
80100b9b:	83 c4 10             	add    $0x10,%esp
80100b9e:	85 c0                	test   %eax,%eax
80100ba0:	0f 84 fe 02 00 00    	je     80100ea4 <exec+0x334>
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100ba6:	83 ec 0c             	sub    $0xc,%esp
80100ba9:	89 c3                	mov    %eax,%ebx
80100bab:	50                   	push   %eax
80100bac:	e8 8f 0d 00 00       	call   80101940 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100bb1:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100bb7:	6a 34                	push   $0x34
80100bb9:	6a 00                	push   $0x0
80100bbb:	50                   	push   %eax
80100bbc:	53                   	push   %ebx
80100bbd:	e8 7e 10 00 00       	call   80101c40 <readi>
80100bc2:	83 c4 20             	add    $0x20,%esp
80100bc5:	83 f8 34             	cmp    $0x34,%eax
80100bc8:	74 26                	je     80100bf0 <exec+0x80>

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
    iunlockput(ip);
80100bca:	83 ec 0c             	sub    $0xc,%esp
80100bcd:	53                   	push   %ebx
80100bce:	e8 0d 10 00 00       	call   80101be0 <iunlockput>
    end_op();
80100bd3:	e8 98 23 00 00       	call   80102f70 <end_op>
80100bd8:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80100bdb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100be0:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100be3:	5b                   	pop    %ebx
80100be4:	5e                   	pop    %esi
80100be5:	5f                   	pop    %edi
80100be6:	5d                   	pop    %ebp
80100be7:	c3                   	ret    
80100be8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100bef:	90                   	nop
  if(elf.magic != ELF_MAGIC)
80100bf0:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
80100bf7:	45 4c 46 
80100bfa:	75 ce                	jne    80100bca <exec+0x5a>
  if((pgdir = setupkvm()) == 0)
80100bfc:	e8 2f 69 00 00       	call   80107530 <setupkvm>
80100c01:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
80100c07:	85 c0                	test   %eax,%eax
80100c09:	74 bf                	je     80100bca <exec+0x5a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c0b:	66 83 bd 50 ff ff ff 	cmpw   $0x0,-0xb0(%ebp)
80100c12:	00 
80100c13:	8b b5 40 ff ff ff    	mov    -0xc0(%ebp),%esi
80100c19:	0f 84 a4 02 00 00    	je     80100ec3 <exec+0x353>
  sz = 0;
80100c1f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
80100c26:	00 00 00 
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c29:	31 ff                	xor    %edi,%edi
80100c2b:	e9 86 00 00 00       	jmp    80100cb6 <exec+0x146>
    if(ph.type != ELF_PROG_LOAD)
80100c30:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100c37:	75 6c                	jne    80100ca5 <exec+0x135>
    if(ph.memsz < ph.filesz)
80100c39:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100c3f:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
80100c45:	0f 82 87 00 00 00    	jb     80100cd2 <exec+0x162>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c4b:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
80100c51:	72 7f                	jb     80100cd2 <exec+0x162>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c53:	83 ec 04             	sub    $0x4,%esp
80100c56:	50                   	push   %eax
80100c57:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100c5d:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100c63:	e8 08 67 00 00       	call   80107370 <allocuvm>
80100c68:	83 c4 10             	add    $0x10,%esp
80100c6b:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100c71:	85 c0                	test   %eax,%eax
80100c73:	74 5d                	je     80100cd2 <exec+0x162>
    if(ph.vaddr % PGSIZE != 0)
80100c75:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100c7b:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100c80:	75 50                	jne    80100cd2 <exec+0x162>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c82:	83 ec 0c             	sub    $0xc,%esp
80100c85:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100c8b:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100c91:	53                   	push   %ebx
80100c92:	50                   	push   %eax
80100c93:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100c99:	e8 02 66 00 00       	call   801072a0 <loaduvm>
80100c9e:	83 c4 20             	add    $0x20,%esp
80100ca1:	85 c0                	test   %eax,%eax
80100ca3:	78 2d                	js     80100cd2 <exec+0x162>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ca5:	0f b7 85 50 ff ff ff 	movzwl -0xb0(%ebp),%eax
80100cac:	83 c7 01             	add    $0x1,%edi
80100caf:	83 c6 20             	add    $0x20,%esi
80100cb2:	39 f8                	cmp    %edi,%eax
80100cb4:	7e 3a                	jle    80100cf0 <exec+0x180>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100cb6:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100cbc:	6a 20                	push   $0x20
80100cbe:	56                   	push   %esi
80100cbf:	50                   	push   %eax
80100cc0:	53                   	push   %ebx
80100cc1:	e8 7a 0f 00 00       	call   80101c40 <readi>
80100cc6:	83 c4 10             	add    $0x10,%esp
80100cc9:	83 f8 20             	cmp    $0x20,%eax
80100ccc:	0f 84 5e ff ff ff    	je     80100c30 <exec+0xc0>
    freevm(pgdir);
80100cd2:	83 ec 0c             	sub    $0xc,%esp
80100cd5:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100cdb:	e8 d0 67 00 00       	call   801074b0 <freevm>
  if(ip){
80100ce0:	83 c4 10             	add    $0x10,%esp
80100ce3:	e9 e2 fe ff ff       	jmp    80100bca <exec+0x5a>
80100ce8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100cef:	90                   	nop
80100cf0:	8b bd f0 fe ff ff    	mov    -0x110(%ebp),%edi
80100cf6:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
80100cfc:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
80100d02:	8d b7 00 20 00 00    	lea    0x2000(%edi),%esi
  iunlockput(ip);
80100d08:	83 ec 0c             	sub    $0xc,%esp
80100d0b:	53                   	push   %ebx
80100d0c:	e8 cf 0e 00 00       	call   80101be0 <iunlockput>
  end_op();
80100d11:	e8 5a 22 00 00       	call   80102f70 <end_op>
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d16:	83 c4 0c             	add    $0xc,%esp
80100d19:	56                   	push   %esi
80100d1a:	57                   	push   %edi
80100d1b:	8b bd f4 fe ff ff    	mov    -0x10c(%ebp),%edi
80100d21:	57                   	push   %edi
80100d22:	e8 49 66 00 00       	call   80107370 <allocuvm>
80100d27:	83 c4 10             	add    $0x10,%esp
80100d2a:	89 c6                	mov    %eax,%esi
80100d2c:	85 c0                	test   %eax,%eax
80100d2e:	0f 84 94 00 00 00    	je     80100dc8 <exec+0x258>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d34:	83 ec 08             	sub    $0x8,%esp
80100d37:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
  for(argc = 0; argv[argc]; argc++) {
80100d3d:	89 f3                	mov    %esi,%ebx
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d3f:	50                   	push   %eax
80100d40:	57                   	push   %edi
  for(argc = 0; argv[argc]; argc++) {
80100d41:	31 ff                	xor    %edi,%edi
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d43:	e8 08 6a 00 00       	call   80107750 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100d48:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d4b:	83 c4 10             	add    $0x10,%esp
80100d4e:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
80100d54:	8b 00                	mov    (%eax),%eax
80100d56:	85 c0                	test   %eax,%eax
80100d58:	0f 84 8b 00 00 00    	je     80100de9 <exec+0x279>
80100d5e:	89 b5 f0 fe ff ff    	mov    %esi,-0x110(%ebp)
80100d64:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100d6a:	eb 23                	jmp    80100d8f <exec+0x21f>
80100d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100d70:	8b 45 0c             	mov    0xc(%ebp),%eax
    ustack[3+argc] = sp;
80100d73:	89 9c bd 64 ff ff ff 	mov    %ebx,-0x9c(%ebp,%edi,4)
  for(argc = 0; argv[argc]; argc++) {
80100d7a:	83 c7 01             	add    $0x1,%edi
    ustack[3+argc] = sp;
80100d7d:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
  for(argc = 0; argv[argc]; argc++) {
80100d83:	8b 04 b8             	mov    (%eax,%edi,4),%eax
80100d86:	85 c0                	test   %eax,%eax
80100d88:	74 59                	je     80100de3 <exec+0x273>
    if(argc >= MAXARG)
80100d8a:	83 ff 20             	cmp    $0x20,%edi
80100d8d:	74 39                	je     80100dc8 <exec+0x258>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d8f:	83 ec 0c             	sub    $0xc,%esp
80100d92:	50                   	push   %eax
80100d93:	e8 88 3c 00 00       	call   80104a20 <strlen>
80100d98:	f7 d0                	not    %eax
80100d9a:	01 c3                	add    %eax,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d9c:	58                   	pop    %eax
80100d9d:	8b 45 0c             	mov    0xc(%ebp),%eax
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100da0:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100da3:	ff 34 b8             	pushl  (%eax,%edi,4)
80100da6:	e8 75 3c 00 00       	call   80104a20 <strlen>
80100dab:	83 c0 01             	add    $0x1,%eax
80100dae:	50                   	push   %eax
80100daf:	8b 45 0c             	mov    0xc(%ebp),%eax
80100db2:	ff 34 b8             	pushl  (%eax,%edi,4)
80100db5:	53                   	push   %ebx
80100db6:	56                   	push   %esi
80100db7:	e8 e4 6b 00 00       	call   801079a0 <copyout>
80100dbc:	83 c4 20             	add    $0x20,%esp
80100dbf:	85 c0                	test   %eax,%eax
80100dc1:	79 ad                	jns    80100d70 <exec+0x200>
80100dc3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100dc7:	90                   	nop
    freevm(pgdir);
80100dc8:	83 ec 0c             	sub    $0xc,%esp
80100dcb:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100dd1:	e8 da 66 00 00       	call   801074b0 <freevm>
80100dd6:	83 c4 10             	add    $0x10,%esp
  return -1;
80100dd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100dde:	e9 fd fd ff ff       	jmp    80100be0 <exec+0x70>
80100de3:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100de9:	8d 04 bd 04 00 00 00 	lea    0x4(,%edi,4),%eax
80100df0:	89 d9                	mov    %ebx,%ecx
  ustack[3+argc] = 0;
80100df2:	c7 84 bd 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%edi,4)
80100df9:	00 00 00 00 
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100dfd:	29 c1                	sub    %eax,%ecx
  sp -= (3+argc+1) * 4;
80100dff:	83 c0 0c             	add    $0xc,%eax
  ustack[1] = argc;
80100e02:	89 bd 5c ff ff ff    	mov    %edi,-0xa4(%ebp)
  sp -= (3+argc+1) * 4;
80100e08:	29 c3                	sub    %eax,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e0a:	50                   	push   %eax
80100e0b:	52                   	push   %edx
80100e0c:	53                   	push   %ebx
80100e0d:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
  ustack[0] = 0xffffffff;  // fake return PC
80100e13:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100e1a:	ff ff ff 
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e1d:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e23:	e8 78 6b 00 00       	call   801079a0 <copyout>
80100e28:	83 c4 10             	add    $0x10,%esp
80100e2b:	85 c0                	test   %eax,%eax
80100e2d:	78 99                	js     80100dc8 <exec+0x258>
  for(last=s=path; *s; s++)
80100e2f:	8b 45 08             	mov    0x8(%ebp),%eax
80100e32:	8b 55 08             	mov    0x8(%ebp),%edx
80100e35:	0f b6 00             	movzbl (%eax),%eax
80100e38:	84 c0                	test   %al,%al
80100e3a:	74 13                	je     80100e4f <exec+0x2df>
80100e3c:	89 d1                	mov    %edx,%ecx
80100e3e:	66 90                	xchg   %ax,%ax
    if(*s == '/')
80100e40:	83 c1 01             	add    $0x1,%ecx
80100e43:	3c 2f                	cmp    $0x2f,%al
  for(last=s=path; *s; s++)
80100e45:	0f b6 01             	movzbl (%ecx),%eax
    if(*s == '/')
80100e48:	0f 44 d1             	cmove  %ecx,%edx
  for(last=s=path; *s; s++)
80100e4b:	84 c0                	test   %al,%al
80100e4d:	75 f1                	jne    80100e40 <exec+0x2d0>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100e4f:	8b bd ec fe ff ff    	mov    -0x114(%ebp),%edi
80100e55:	83 ec 04             	sub    $0x4,%esp
80100e58:	6a 10                	push   $0x10
80100e5a:	89 f8                	mov    %edi,%eax
80100e5c:	52                   	push   %edx
80100e5d:	83 c0 6c             	add    $0x6c,%eax
80100e60:	50                   	push   %eax
80100e61:	e8 7a 3b 00 00       	call   801049e0 <safestrcpy>
  curproc->pgdir = pgdir;
80100e66:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
  oldpgdir = curproc->pgdir;
80100e6c:	89 f8                	mov    %edi,%eax
80100e6e:	8b 7f 04             	mov    0x4(%edi),%edi
  curproc->sz = sz;
80100e71:	89 30                	mov    %esi,(%eax)
  curproc->pgdir = pgdir;
80100e73:	89 48 04             	mov    %ecx,0x4(%eax)
  curproc->tf->eip = elf.entry;  // main
80100e76:	89 c1                	mov    %eax,%ecx
80100e78:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100e7e:	8b 40 18             	mov    0x18(%eax),%eax
80100e81:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100e84:	8b 41 18             	mov    0x18(%ecx),%eax
80100e87:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(curproc);
80100e8a:	89 0c 24             	mov    %ecx,(%esp)
80100e8d:	e8 7e 62 00 00       	call   80107110 <switchuvm>
  freevm(oldpgdir);
80100e92:	89 3c 24             	mov    %edi,(%esp)
80100e95:	e8 16 66 00 00       	call   801074b0 <freevm>
  return 0;
80100e9a:	83 c4 10             	add    $0x10,%esp
80100e9d:	31 c0                	xor    %eax,%eax
80100e9f:	e9 3c fd ff ff       	jmp    80100be0 <exec+0x70>
    end_op();
80100ea4:	e8 c7 20 00 00       	call   80102f70 <end_op>
    cprintf("exec: fail\n");
80100ea9:	83 ec 0c             	sub    $0xc,%esp
80100eac:	68 c1 7a 10 80       	push   $0x80107ac1
80100eb1:	e8 ea f8 ff ff       	call   801007a0 <cprintf>
    return -1;
80100eb6:	83 c4 10             	add    $0x10,%esp
80100eb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ebe:	e9 1d fd ff ff       	jmp    80100be0 <exec+0x70>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ec3:	31 ff                	xor    %edi,%edi
80100ec5:	be 00 20 00 00       	mov    $0x2000,%esi
80100eca:	e9 39 fe ff ff       	jmp    80100d08 <exec+0x198>
80100ecf:	90                   	nop

80100ed0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100ed0:	f3 0f 1e fb          	endbr32 
80100ed4:	55                   	push   %ebp
80100ed5:	89 e5                	mov    %esp,%ebp
80100ed7:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100eda:	68 cd 7a 10 80       	push   $0x80107acd
80100edf:	68 c0 0f 11 80       	push   $0x80110fc0
80100ee4:	e8 a7 36 00 00       	call   80104590 <initlock>
}
80100ee9:	83 c4 10             	add    $0x10,%esp
80100eec:	c9                   	leave  
80100eed:	c3                   	ret    
80100eee:	66 90                	xchg   %ax,%ax

80100ef0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100ef0:	f3 0f 1e fb          	endbr32 
80100ef4:	55                   	push   %ebp
80100ef5:	89 e5                	mov    %esp,%ebp
80100ef7:	53                   	push   %ebx
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ef8:	bb f4 0f 11 80       	mov    $0x80110ff4,%ebx
{
80100efd:	83 ec 10             	sub    $0x10,%esp
  acquire(&ftable.lock);
80100f00:	68 c0 0f 11 80       	push   $0x80110fc0
80100f05:	e8 96 37 00 00       	call   801046a0 <acquire>
80100f0a:	83 c4 10             	add    $0x10,%esp
80100f0d:	eb 0c                	jmp    80100f1b <filealloc+0x2b>
80100f0f:	90                   	nop
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f10:	83 c3 18             	add    $0x18,%ebx
80100f13:	81 fb 54 19 11 80    	cmp    $0x80111954,%ebx
80100f19:	74 25                	je     80100f40 <filealloc+0x50>
    if(f->ref == 0){
80100f1b:	8b 43 04             	mov    0x4(%ebx),%eax
80100f1e:	85 c0                	test   %eax,%eax
80100f20:	75 ee                	jne    80100f10 <filealloc+0x20>
      f->ref = 1;
      release(&ftable.lock);
80100f22:	83 ec 0c             	sub    $0xc,%esp
      f->ref = 1;
80100f25:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100f2c:	68 c0 0f 11 80       	push   $0x80110fc0
80100f31:	e8 9a 38 00 00       	call   801047d0 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
80100f36:	89 d8                	mov    %ebx,%eax
      return f;
80100f38:	83 c4 10             	add    $0x10,%esp
}
80100f3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100f3e:	c9                   	leave  
80100f3f:	c3                   	ret    
  release(&ftable.lock);
80100f40:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80100f43:	31 db                	xor    %ebx,%ebx
  release(&ftable.lock);
80100f45:	68 c0 0f 11 80       	push   $0x80110fc0
80100f4a:	e8 81 38 00 00       	call   801047d0 <release>
}
80100f4f:	89 d8                	mov    %ebx,%eax
  return 0;
80100f51:	83 c4 10             	add    $0x10,%esp
}
80100f54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100f57:	c9                   	leave  
80100f58:	c3                   	ret    
80100f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100f60 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f60:	f3 0f 1e fb          	endbr32 
80100f64:	55                   	push   %ebp
80100f65:	89 e5                	mov    %esp,%ebp
80100f67:	53                   	push   %ebx
80100f68:	83 ec 10             	sub    $0x10,%esp
80100f6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100f6e:	68 c0 0f 11 80       	push   $0x80110fc0
80100f73:	e8 28 37 00 00       	call   801046a0 <acquire>
  if(f->ref < 1)
80100f78:	8b 43 04             	mov    0x4(%ebx),%eax
80100f7b:	83 c4 10             	add    $0x10,%esp
80100f7e:	85 c0                	test   %eax,%eax
80100f80:	7e 1a                	jle    80100f9c <filedup+0x3c>
    panic("filedup");
  f->ref++;
80100f82:	83 c0 01             	add    $0x1,%eax
  release(&ftable.lock);
80100f85:	83 ec 0c             	sub    $0xc,%esp
  f->ref++;
80100f88:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100f8b:	68 c0 0f 11 80       	push   $0x80110fc0
80100f90:	e8 3b 38 00 00       	call   801047d0 <release>
  return f;
}
80100f95:	89 d8                	mov    %ebx,%eax
80100f97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100f9a:	c9                   	leave  
80100f9b:	c3                   	ret    
    panic("filedup");
80100f9c:	83 ec 0c             	sub    $0xc,%esp
80100f9f:	68 d4 7a 10 80       	push   $0x80107ad4
80100fa4:	e8 d7 f4 ff ff       	call   80100480 <panic>
80100fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100fb0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fb0:	f3 0f 1e fb          	endbr32 
80100fb4:	55                   	push   %ebp
80100fb5:	89 e5                	mov    %esp,%ebp
80100fb7:	57                   	push   %edi
80100fb8:	56                   	push   %esi
80100fb9:	53                   	push   %ebx
80100fba:	83 ec 28             	sub    $0x28,%esp
80100fbd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100fc0:	68 c0 0f 11 80       	push   $0x80110fc0
80100fc5:	e8 d6 36 00 00       	call   801046a0 <acquire>
  if(f->ref < 1)
80100fca:	8b 53 04             	mov    0x4(%ebx),%edx
80100fcd:	83 c4 10             	add    $0x10,%esp
80100fd0:	85 d2                	test   %edx,%edx
80100fd2:	0f 8e a1 00 00 00    	jle    80101079 <fileclose+0xc9>
    panic("fileclose");
  if(--f->ref > 0){
80100fd8:	83 ea 01             	sub    $0x1,%edx
80100fdb:	89 53 04             	mov    %edx,0x4(%ebx)
80100fde:	75 40                	jne    80101020 <fileclose+0x70>
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100fe0:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
80100fe4:	83 ec 0c             	sub    $0xc,%esp
  ff = *f;
80100fe7:	8b 3b                	mov    (%ebx),%edi
  f->type = FD_NONE;
80100fe9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  ff = *f;
80100fef:	8b 73 0c             	mov    0xc(%ebx),%esi
80100ff2:	88 45 e7             	mov    %al,-0x19(%ebp)
80100ff5:	8b 43 10             	mov    0x10(%ebx),%eax
  release(&ftable.lock);
80100ff8:	68 c0 0f 11 80       	push   $0x80110fc0
  ff = *f;
80100ffd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  release(&ftable.lock);
80101000:	e8 cb 37 00 00       	call   801047d0 <release>

  if(ff.type == FD_PIPE)
80101005:	83 c4 10             	add    $0x10,%esp
80101008:	83 ff 01             	cmp    $0x1,%edi
8010100b:	74 53                	je     80101060 <fileclose+0xb0>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
8010100d:	83 ff 02             	cmp    $0x2,%edi
80101010:	74 26                	je     80101038 <fileclose+0x88>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80101012:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101015:	5b                   	pop    %ebx
80101016:	5e                   	pop    %esi
80101017:	5f                   	pop    %edi
80101018:	5d                   	pop    %ebp
80101019:	c3                   	ret    
8010101a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    release(&ftable.lock);
80101020:	c7 45 08 c0 0f 11 80 	movl   $0x80110fc0,0x8(%ebp)
}
80101027:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010102a:	5b                   	pop    %ebx
8010102b:	5e                   	pop    %esi
8010102c:	5f                   	pop    %edi
8010102d:	5d                   	pop    %ebp
    release(&ftable.lock);
8010102e:	e9 9d 37 00 00       	jmp    801047d0 <release>
80101033:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101037:	90                   	nop
    begin_op();
80101038:	e8 c3 1e 00 00       	call   80102f00 <begin_op>
    iput(ff.ip);
8010103d:	83 ec 0c             	sub    $0xc,%esp
80101040:	ff 75 e0             	pushl  -0x20(%ebp)
80101043:	e8 28 0a 00 00       	call   80101a70 <iput>
    end_op();
80101048:	83 c4 10             	add    $0x10,%esp
}
8010104b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010104e:	5b                   	pop    %ebx
8010104f:	5e                   	pop    %esi
80101050:	5f                   	pop    %edi
80101051:	5d                   	pop    %ebp
    end_op();
80101052:	e9 19 1f 00 00       	jmp    80102f70 <end_op>
80101057:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010105e:	66 90                	xchg   %ax,%ax
    pipeclose(ff.pipe, ff.writable);
80101060:	0f be 5d e7          	movsbl -0x19(%ebp),%ebx
80101064:	83 ec 08             	sub    $0x8,%esp
80101067:	53                   	push   %ebx
80101068:	56                   	push   %esi
80101069:	e8 62 26 00 00       	call   801036d0 <pipeclose>
8010106e:	83 c4 10             	add    $0x10,%esp
}
80101071:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101074:	5b                   	pop    %ebx
80101075:	5e                   	pop    %esi
80101076:	5f                   	pop    %edi
80101077:	5d                   	pop    %ebp
80101078:	c3                   	ret    
    panic("fileclose");
80101079:	83 ec 0c             	sub    $0xc,%esp
8010107c:	68 dc 7a 10 80       	push   $0x80107adc
80101081:	e8 fa f3 ff ff       	call   80100480 <panic>
80101086:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010108d:	8d 76 00             	lea    0x0(%esi),%esi

80101090 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101090:	f3 0f 1e fb          	endbr32 
80101094:	55                   	push   %ebp
80101095:	89 e5                	mov    %esp,%ebp
80101097:	53                   	push   %ebx
80101098:	83 ec 04             	sub    $0x4,%esp
8010109b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
8010109e:	83 3b 02             	cmpl   $0x2,(%ebx)
801010a1:	75 2d                	jne    801010d0 <filestat+0x40>
    ilock(f->ip);
801010a3:	83 ec 0c             	sub    $0xc,%esp
801010a6:	ff 73 10             	pushl  0x10(%ebx)
801010a9:	e8 92 08 00 00       	call   80101940 <ilock>
    stati(f->ip, st);
801010ae:	58                   	pop    %eax
801010af:	5a                   	pop    %edx
801010b0:	ff 75 0c             	pushl  0xc(%ebp)
801010b3:	ff 73 10             	pushl  0x10(%ebx)
801010b6:	e8 55 0b 00 00       	call   80101c10 <stati>
    iunlock(f->ip);
801010bb:	59                   	pop    %ecx
801010bc:	ff 73 10             	pushl  0x10(%ebx)
801010bf:	e8 5c 09 00 00       	call   80101a20 <iunlock>
    return 0;
  }
  return -1;
}
801010c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return 0;
801010c7:	83 c4 10             	add    $0x10,%esp
801010ca:	31 c0                	xor    %eax,%eax
}
801010cc:	c9                   	leave  
801010cd:	c3                   	ret    
801010ce:	66 90                	xchg   %ax,%ax
801010d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
801010d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010d8:	c9                   	leave  
801010d9:	c3                   	ret    
801010da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801010e0 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801010e0:	f3 0f 1e fb          	endbr32 
801010e4:	55                   	push   %ebp
801010e5:	89 e5                	mov    %esp,%ebp
801010e7:	57                   	push   %edi
801010e8:	56                   	push   %esi
801010e9:	53                   	push   %ebx
801010ea:	83 ec 0c             	sub    $0xc,%esp
801010ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
801010f0:	8b 75 0c             	mov    0xc(%ebp),%esi
801010f3:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
801010f6:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
801010fa:	74 64                	je     80101160 <fileread+0x80>
    return -1;
  if(f->type == FD_PIPE)
801010fc:	8b 03                	mov    (%ebx),%eax
801010fe:	83 f8 01             	cmp    $0x1,%eax
80101101:	74 45                	je     80101148 <fileread+0x68>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80101103:	83 f8 02             	cmp    $0x2,%eax
80101106:	75 5f                	jne    80101167 <fileread+0x87>
    ilock(f->ip);
80101108:	83 ec 0c             	sub    $0xc,%esp
8010110b:	ff 73 10             	pushl  0x10(%ebx)
8010110e:	e8 2d 08 00 00       	call   80101940 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101113:	57                   	push   %edi
80101114:	ff 73 14             	pushl  0x14(%ebx)
80101117:	56                   	push   %esi
80101118:	ff 73 10             	pushl  0x10(%ebx)
8010111b:	e8 20 0b 00 00       	call   80101c40 <readi>
80101120:	83 c4 20             	add    $0x20,%esp
80101123:	89 c6                	mov    %eax,%esi
80101125:	85 c0                	test   %eax,%eax
80101127:	7e 03                	jle    8010112c <fileread+0x4c>
      f->off += r;
80101129:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
8010112c:	83 ec 0c             	sub    $0xc,%esp
8010112f:	ff 73 10             	pushl  0x10(%ebx)
80101132:	e8 e9 08 00 00       	call   80101a20 <iunlock>
    return r;
80101137:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
8010113a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010113d:	89 f0                	mov    %esi,%eax
8010113f:	5b                   	pop    %ebx
80101140:	5e                   	pop    %esi
80101141:	5f                   	pop    %edi
80101142:	5d                   	pop    %ebp
80101143:	c3                   	ret    
80101144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return piperead(f->pipe, addr, n);
80101148:	8b 43 0c             	mov    0xc(%ebx),%eax
8010114b:	89 45 08             	mov    %eax,0x8(%ebp)
}
8010114e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101151:	5b                   	pop    %ebx
80101152:	5e                   	pop    %esi
80101153:	5f                   	pop    %edi
80101154:	5d                   	pop    %ebp
    return piperead(f->pipe, addr, n);
80101155:	e9 16 27 00 00       	jmp    80103870 <piperead>
8010115a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80101160:	be ff ff ff ff       	mov    $0xffffffff,%esi
80101165:	eb d3                	jmp    8010113a <fileread+0x5a>
  panic("fileread");
80101167:	83 ec 0c             	sub    $0xc,%esp
8010116a:	68 e6 7a 10 80       	push   $0x80107ae6
8010116f:	e8 0c f3 ff ff       	call   80100480 <panic>
80101174:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010117b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010117f:	90                   	nop

80101180 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101180:	f3 0f 1e fb          	endbr32 
80101184:	55                   	push   %ebp
80101185:	89 e5                	mov    %esp,%ebp
80101187:	57                   	push   %edi
80101188:	56                   	push   %esi
80101189:	53                   	push   %ebx
8010118a:	83 ec 1c             	sub    $0x1c,%esp
8010118d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101190:	8b 75 08             	mov    0x8(%ebp),%esi
80101193:	89 45 dc             	mov    %eax,-0x24(%ebp)
80101196:	8b 45 10             	mov    0x10(%ebp),%eax
  int r;

  if(f->writable == 0)
80101199:	80 7e 09 00          	cmpb   $0x0,0x9(%esi)
{
8010119d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(f->writable == 0)
801011a0:	0f 84 c1 00 00 00    	je     80101267 <filewrite+0xe7>
    return -1;
  if(f->type == FD_PIPE)
801011a6:	8b 06                	mov    (%esi),%eax
801011a8:	83 f8 01             	cmp    $0x1,%eax
801011ab:	0f 84 c3 00 00 00    	je     80101274 <filewrite+0xf4>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
801011b1:	83 f8 02             	cmp    $0x2,%eax
801011b4:	0f 85 cc 00 00 00    	jne    80101286 <filewrite+0x106>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801011ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    int i = 0;
801011bd:	31 ff                	xor    %edi,%edi
    while(i < n){
801011bf:	85 c0                	test   %eax,%eax
801011c1:	7f 34                	jg     801011f7 <filewrite+0x77>
801011c3:	e9 98 00 00 00       	jmp    80101260 <filewrite+0xe0>
801011c8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801011cf:	90                   	nop
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
801011d0:	01 46 14             	add    %eax,0x14(%esi)
      iunlock(f->ip);
801011d3:	83 ec 0c             	sub    $0xc,%esp
801011d6:	ff 76 10             	pushl  0x10(%esi)
        f->off += r;
801011d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
      iunlock(f->ip);
801011dc:	e8 3f 08 00 00       	call   80101a20 <iunlock>
      end_op();
801011e1:	e8 8a 1d 00 00       	call   80102f70 <end_op>

      if(r < 0)
        break;
      if(r != n1)
801011e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011e9:	83 c4 10             	add    $0x10,%esp
801011ec:	39 c3                	cmp    %eax,%ebx
801011ee:	75 60                	jne    80101250 <filewrite+0xd0>
        panic("short filewrite");
      i += r;
801011f0:	01 df                	add    %ebx,%edi
    while(i < n){
801011f2:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
801011f5:	7e 69                	jle    80101260 <filewrite+0xe0>
      int n1 = n - i;
801011f7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801011fa:	b8 00 06 00 00       	mov    $0x600,%eax
801011ff:	29 fb                	sub    %edi,%ebx
      if(n1 > max)
80101201:	81 fb 00 06 00 00    	cmp    $0x600,%ebx
80101207:	0f 4f d8             	cmovg  %eax,%ebx
      begin_op();
8010120a:	e8 f1 1c 00 00       	call   80102f00 <begin_op>
      ilock(f->ip);
8010120f:	83 ec 0c             	sub    $0xc,%esp
80101212:	ff 76 10             	pushl  0x10(%esi)
80101215:	e8 26 07 00 00       	call   80101940 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010121a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010121d:	53                   	push   %ebx
8010121e:	ff 76 14             	pushl  0x14(%esi)
80101221:	01 f8                	add    %edi,%eax
80101223:	50                   	push   %eax
80101224:	ff 76 10             	pushl  0x10(%esi)
80101227:	e8 14 0b 00 00       	call   80101d40 <writei>
8010122c:	83 c4 20             	add    $0x20,%esp
8010122f:	85 c0                	test   %eax,%eax
80101231:	7f 9d                	jg     801011d0 <filewrite+0x50>
      iunlock(f->ip);
80101233:	83 ec 0c             	sub    $0xc,%esp
80101236:	ff 76 10             	pushl  0x10(%esi)
80101239:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010123c:	e8 df 07 00 00       	call   80101a20 <iunlock>
      end_op();
80101241:	e8 2a 1d 00 00       	call   80102f70 <end_op>
      if(r < 0)
80101246:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101249:	83 c4 10             	add    $0x10,%esp
8010124c:	85 c0                	test   %eax,%eax
8010124e:	75 17                	jne    80101267 <filewrite+0xe7>
        panic("short filewrite");
80101250:	83 ec 0c             	sub    $0xc,%esp
80101253:	68 ef 7a 10 80       	push   $0x80107aef
80101258:	e8 23 f2 ff ff       	call   80100480 <panic>
8010125d:	8d 76 00             	lea    0x0(%esi),%esi
    }
    return i == n ? n : -1;
80101260:	89 f8                	mov    %edi,%eax
80101262:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
80101265:	74 05                	je     8010126c <filewrite+0xec>
80101267:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
8010126c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010126f:	5b                   	pop    %ebx
80101270:	5e                   	pop    %esi
80101271:	5f                   	pop    %edi
80101272:	5d                   	pop    %ebp
80101273:	c3                   	ret    
    return pipewrite(f->pipe, addr, n);
80101274:	8b 46 0c             	mov    0xc(%esi),%eax
80101277:	89 45 08             	mov    %eax,0x8(%ebp)
}
8010127a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010127d:	5b                   	pop    %ebx
8010127e:	5e                   	pop    %esi
8010127f:	5f                   	pop    %edi
80101280:	5d                   	pop    %ebp
    return pipewrite(f->pipe, addr, n);
80101281:	e9 ea 24 00 00       	jmp    80103770 <pipewrite>
  panic("filewrite");
80101286:	83 ec 0c             	sub    $0xc,%esp
80101289:	68 f5 7a 10 80       	push   $0x80107af5
8010128e:	e8 ed f1 ff ff       	call   80100480 <panic>
80101293:	66 90                	xchg   %ax,%ax
80101295:	66 90                	xchg   %ax,%ax
80101297:	66 90                	xchg   %ax,%ax
80101299:	66 90                	xchg   %ax,%ax
8010129b:	66 90                	xchg   %ax,%ax
8010129d:	66 90                	xchg   %ax,%ax
8010129f:	90                   	nop

801012a0 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801012a0:	55                   	push   %ebp
801012a1:	89 e5                	mov    %esp,%ebp
801012a3:	57                   	push   %edi
801012a4:	56                   	push   %esi
801012a5:	53                   	push   %ebx
801012a6:	83 ec 1c             	sub    $0x1c,%esp
  int b, bi, m;
  struct buf *bp;
  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801012a9:	8b 0d c0 19 11 80    	mov    0x801119c0,%ecx
{
801012af:	89 45 dc             	mov    %eax,-0x24(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801012b2:	85 c9                	test   %ecx,%ecx
801012b4:	0f 84 80 00 00 00    	je     8010133a <balloc+0x9a>
801012ba:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
801012c1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
801012c4:	83 ec 08             	sub    $0x8,%esp
801012c7:	89 d8                	mov    %ebx,%eax
801012c9:	c1 f8 0c             	sar    $0xc,%eax
801012cc:	03 05 d8 19 11 80    	add    0x801119d8,%eax
801012d2:	50                   	push   %eax
801012d3:	ff 75 dc             	pushl  -0x24(%ebp)
801012d6:	e8 b5 ee ff ff       	call   80100190 <bread>
801012db:	83 c4 10             	add    $0x10,%esp
801012de:	89 c2                	mov    %eax,%edx
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801012e0:	a1 c0 19 11 80       	mov    0x801119c0,%eax
801012e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801012e8:	31 c0                	xor    %eax,%eax
801012ea:	eb 2b                	jmp    80101317 <balloc+0x77>
801012ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      m = 1 << (bi % 8);
801012f0:	89 c1                	mov    %eax,%ecx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801012f2:	89 c6                	mov    %eax,%esi
      m = 1 << (bi % 8);
801012f4:	bf 01 00 00 00       	mov    $0x1,%edi
801012f9:	83 e1 07             	and    $0x7,%ecx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801012fc:	c1 fe 03             	sar    $0x3,%esi
      m = 1 << (bi % 8);
801012ff:	d3 e7                	shl    %cl,%edi
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101301:	0f b6 4c 32 5c       	movzbl 0x5c(%edx,%esi,1),%ecx
80101306:	85 f9                	test   %edi,%ecx
80101308:	74 46                	je     80101350 <balloc+0xb0>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010130a:	83 c0 01             	add    $0x1,%eax
8010130d:	83 c3 01             	add    $0x1,%ebx
80101310:	3d 00 10 00 00       	cmp    $0x1000,%eax
80101315:	74 05                	je     8010131c <balloc+0x7c>
80101317:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
8010131a:	77 d4                	ja     801012f0 <balloc+0x50>
        bzero(dev, b + bi);
        end_op();
        return b + bi;
      }
    }
    brelse(bp);
8010131c:	83 ec 0c             	sub    $0xc,%esp
8010131f:	52                   	push   %edx
80101320:	e8 eb ee ff ff       	call   80100210 <brelse>
  for(b = 0; b < sb.size; b += BPB){
80101325:	81 45 e0 00 10 00 00 	addl   $0x1000,-0x20(%ebp)
8010132c:	83 c4 10             	add    $0x10,%esp
8010132f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101332:	39 05 c0 19 11 80    	cmp    %eax,0x801119c0
80101338:	77 87                	ja     801012c1 <balloc+0x21>
  }
  panic("balloc: out of blocks");
8010133a:	83 ec 0c             	sub    $0xc,%esp
8010133d:	68 ff 7a 10 80       	push   $0x80107aff
80101342:	e8 39 f1 ff ff       	call   80100480 <panic>
80101347:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010134e:	66 90                	xchg   %ax,%ax
80101350:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        begin_op();
80101353:	e8 a8 1b 00 00       	call   80102f00 <begin_op>
        bp->data[bi/8] |= m;  // Mark block in use.
80101358:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        log_write(bp);
8010135b:	83 ec 0c             	sub    $0xc,%esp
        bp->data[bi/8] |= m;  // Mark block in use.
8010135e:	89 f8                	mov    %edi,%eax
80101360:	08 44 32 5c          	or     %al,0x5c(%edx,%esi,1)
        log_write(bp);
80101364:	52                   	push   %edx
80101365:	e8 76 1d 00 00       	call   801030e0 <log_write>
        brelse(bp);
8010136a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010136d:	89 14 24             	mov    %edx,(%esp)
80101370:	e8 9b ee ff ff       	call   80100210 <brelse>
  bp = bread(dev, bno);
80101375:	58                   	pop    %eax
80101376:	5a                   	pop    %edx
80101377:	53                   	push   %ebx
80101378:	ff 75 dc             	pushl  -0x24(%ebp)
8010137b:	e8 10 ee ff ff       	call   80100190 <bread>
  memset(bp->data, 0, BSIZE);
80101380:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, bno);
80101383:	89 c6                	mov    %eax,%esi
  memset(bp->data, 0, BSIZE);
80101385:	8d 40 5c             	lea    0x5c(%eax),%eax
80101388:	68 00 02 00 00       	push   $0x200
8010138d:	6a 00                	push   $0x0
8010138f:	50                   	push   %eax
80101390:	e8 8b 34 00 00       	call   80104820 <memset>
  log_write(bp);
80101395:	89 34 24             	mov    %esi,(%esp)
80101398:	e8 43 1d 00 00       	call   801030e0 <log_write>
  brelse(bp);
8010139d:	89 34 24             	mov    %esi,(%esp)
801013a0:	e8 6b ee ff ff       	call   80100210 <brelse>
        end_op();
801013a5:	e8 c6 1b 00 00       	call   80102f70 <end_op>
}
801013aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
801013ad:	89 d8                	mov    %ebx,%eax
801013af:	5b                   	pop    %ebx
801013b0:	5e                   	pop    %esi
801013b1:	5f                   	pop    %edi
801013b2:	5d                   	pop    %ebp
801013b3:	c3                   	ret    
801013b4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801013bb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801013bf:	90                   	nop

801013c0 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801013c0:	55                   	push   %ebp
801013c1:	89 e5                	mov    %esp,%ebp
801013c3:	57                   	push   %edi
801013c4:	89 c7                	mov    %eax,%edi
801013c6:	56                   	push   %esi
  struct inode *ip, *empty;

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
801013c7:	31 f6                	xor    %esi,%esi
{
801013c9:	53                   	push   %ebx
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801013ca:	bb 14 1a 11 80       	mov    $0x80111a14,%ebx
{
801013cf:	83 ec 28             	sub    $0x28,%esp
801013d2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
801013d5:	68 e0 19 11 80       	push   $0x801119e0
801013da:	e8 c1 32 00 00       	call   801046a0 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801013df:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  acquire(&icache.lock);
801013e2:	83 c4 10             	add    $0x10,%esp
801013e5:	eb 1b                	jmp    80101402 <iget+0x42>
801013e7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801013ee:	66 90                	xchg   %ax,%ax
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801013f0:	39 3b                	cmp    %edi,(%ebx)
801013f2:	74 6c                	je     80101460 <iget+0xa0>
801013f4:	81 c3 90 00 00 00    	add    $0x90,%ebx
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801013fa:	81 fb 34 36 11 80    	cmp    $0x80113634,%ebx
80101400:	73 26                	jae    80101428 <iget+0x68>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101402:	8b 4b 08             	mov    0x8(%ebx),%ecx
80101405:	85 c9                	test   %ecx,%ecx
80101407:	7f e7                	jg     801013f0 <iget+0x30>
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101409:	85 f6                	test   %esi,%esi
8010140b:	75 e7                	jne    801013f4 <iget+0x34>
8010140d:	89 d8                	mov    %ebx,%eax
8010140f:	81 c3 90 00 00 00    	add    $0x90,%ebx
80101415:	85 c9                	test   %ecx,%ecx
80101417:	75 6e                	jne    80101487 <iget+0xc7>
80101419:	89 c6                	mov    %eax,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010141b:	81 fb 34 36 11 80    	cmp    $0x80113634,%ebx
80101421:	72 df                	jb     80101402 <iget+0x42>
80101423:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101427:	90                   	nop
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101428:	85 f6                	test   %esi,%esi
8010142a:	74 73                	je     8010149f <iget+0xdf>
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->valid = 0;
  release(&icache.lock);
8010142c:	83 ec 0c             	sub    $0xc,%esp
  ip->dev = dev;
8010142f:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
80101431:	89 56 04             	mov    %edx,0x4(%esi)
  ip->ref = 1;
80101434:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
8010143b:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
80101442:	68 e0 19 11 80       	push   $0x801119e0
80101447:	e8 84 33 00 00       	call   801047d0 <release>

  return ip;
8010144c:	83 c4 10             	add    $0x10,%esp
}
8010144f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101452:	89 f0                	mov    %esi,%eax
80101454:	5b                   	pop    %ebx
80101455:	5e                   	pop    %esi
80101456:	5f                   	pop    %edi
80101457:	5d                   	pop    %ebp
80101458:	c3                   	ret    
80101459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101460:	39 53 04             	cmp    %edx,0x4(%ebx)
80101463:	75 8f                	jne    801013f4 <iget+0x34>
      release(&icache.lock);
80101465:	83 ec 0c             	sub    $0xc,%esp
      ip->ref++;
80101468:	83 c1 01             	add    $0x1,%ecx
      return ip;
8010146b:	89 de                	mov    %ebx,%esi
      release(&icache.lock);
8010146d:	68 e0 19 11 80       	push   $0x801119e0
      ip->ref++;
80101472:	89 4b 08             	mov    %ecx,0x8(%ebx)
      release(&icache.lock);
80101475:	e8 56 33 00 00       	call   801047d0 <release>
      return ip;
8010147a:	83 c4 10             	add    $0x10,%esp
}
8010147d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101480:	89 f0                	mov    %esi,%eax
80101482:	5b                   	pop    %ebx
80101483:	5e                   	pop    %esi
80101484:	5f                   	pop    %edi
80101485:	5d                   	pop    %ebp
80101486:	c3                   	ret    
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101487:	81 fb 34 36 11 80    	cmp    $0x80113634,%ebx
8010148d:	73 10                	jae    8010149f <iget+0xdf>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010148f:	8b 4b 08             	mov    0x8(%ebx),%ecx
80101492:	85 c9                	test   %ecx,%ecx
80101494:	0f 8f 56 ff ff ff    	jg     801013f0 <iget+0x30>
8010149a:	e9 6e ff ff ff       	jmp    8010140d <iget+0x4d>
    panic("iget: no inodes");
8010149f:	83 ec 0c             	sub    $0xc,%esp
801014a2:	68 15 7b 10 80       	push   $0x80107b15
801014a7:	e8 d4 ef ff ff       	call   80100480 <panic>
801014ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801014b0 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
801014b0:	55                   	push   %ebp
801014b1:	89 e5                	mov    %esp,%ebp
801014b3:	57                   	push   %edi
801014b4:	56                   	push   %esi
801014b5:	89 c6                	mov    %eax,%esi
801014b7:	53                   	push   %ebx
801014b8:	83 ec 1c             	sub    $0x1c,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
801014bb:	83 fa 0b             	cmp    $0xb,%edx
801014be:	0f 86 84 00 00 00    	jbe    80101548 <bmap+0x98>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
801014c4:	8d 5a f4             	lea    -0xc(%edx),%ebx

  if(bn < NINDIRECT){
801014c7:	83 fb 7f             	cmp    $0x7f,%ebx
801014ca:	0f 87 98 00 00 00    	ja     80101568 <bmap+0xb8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
801014d0:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801014d6:	8b 16                	mov    (%esi),%edx
801014d8:	85 c0                	test   %eax,%eax
801014da:	74 54                	je     80101530 <bmap+0x80>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
801014dc:	83 ec 08             	sub    $0x8,%esp
801014df:	50                   	push   %eax
801014e0:	52                   	push   %edx
801014e1:	e8 aa ec ff ff       	call   80100190 <bread>
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
801014e6:	83 c4 10             	add    $0x10,%esp
801014e9:	8d 54 98 5c          	lea    0x5c(%eax,%ebx,4),%edx
    bp = bread(ip->dev, addr);
801014ed:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
801014ef:	8b 1a                	mov    (%edx),%ebx
801014f1:	85 db                	test   %ebx,%ebx
801014f3:	74 1b                	je     80101510 <bmap+0x60>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
801014f5:	83 ec 0c             	sub    $0xc,%esp
801014f8:	57                   	push   %edi
801014f9:	e8 12 ed ff ff       	call   80100210 <brelse>
    return addr;
801014fe:	83 c4 10             	add    $0x10,%esp
  }

  panic("bmap: out of range");
}
80101501:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101504:	89 d8                	mov    %ebx,%eax
80101506:	5b                   	pop    %ebx
80101507:	5e                   	pop    %esi
80101508:	5f                   	pop    %edi
80101509:	5d                   	pop    %ebp
8010150a:	c3                   	ret    
8010150b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010150f:	90                   	nop
      a[bn] = addr = balloc(ip->dev);
80101510:	8b 06                	mov    (%esi),%eax
80101512:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101515:	e8 86 fd ff ff       	call   801012a0 <balloc>
8010151a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      log_write(bp);
8010151d:	83 ec 0c             	sub    $0xc,%esp
      a[bn] = addr = balloc(ip->dev);
80101520:	89 c3                	mov    %eax,%ebx
80101522:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101524:	57                   	push   %edi
80101525:	e8 b6 1b 00 00       	call   801030e0 <log_write>
8010152a:	83 c4 10             	add    $0x10,%esp
8010152d:	eb c6                	jmp    801014f5 <bmap+0x45>
8010152f:	90                   	nop
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101530:	89 d0                	mov    %edx,%eax
80101532:	e8 69 fd ff ff       	call   801012a0 <balloc>
80101537:	8b 16                	mov    (%esi),%edx
80101539:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
8010153f:	eb 9b                	jmp    801014dc <bmap+0x2c>
80101541:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if((addr = ip->addrs[bn]) == 0)
80101548:	8d 3c 90             	lea    (%eax,%edx,4),%edi
8010154b:	8b 5f 5c             	mov    0x5c(%edi),%ebx
8010154e:	85 db                	test   %ebx,%ebx
80101550:	75 af                	jne    80101501 <bmap+0x51>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101552:	8b 00                	mov    (%eax),%eax
80101554:	e8 47 fd ff ff       	call   801012a0 <balloc>
80101559:	89 47 5c             	mov    %eax,0x5c(%edi)
8010155c:	89 c3                	mov    %eax,%ebx
}
8010155e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101561:	89 d8                	mov    %ebx,%eax
80101563:	5b                   	pop    %ebx
80101564:	5e                   	pop    %esi
80101565:	5f                   	pop    %edi
80101566:	5d                   	pop    %ebp
80101567:	c3                   	ret    
  panic("bmap: out of range");
80101568:	83 ec 0c             	sub    $0xc,%esp
8010156b:	68 25 7b 10 80       	push   $0x80107b25
80101570:	e8 0b ef ff ff       	call   80100480 <panic>
80101575:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010157c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101580 <readsb>:
{
80101580:	f3 0f 1e fb          	endbr32 
80101584:	55                   	push   %ebp
80101585:	89 e5                	mov    %esp,%ebp
80101587:	56                   	push   %esi
80101588:	53                   	push   %ebx
80101589:	8b 75 0c             	mov    0xc(%ebp),%esi
  bp = bread(dev, 1);
8010158c:	83 ec 08             	sub    $0x8,%esp
8010158f:	6a 01                	push   $0x1
80101591:	ff 75 08             	pushl  0x8(%ebp)
80101594:	e8 f7 eb ff ff       	call   80100190 <bread>
  memmove(sb, bp->data, sizeof(*sb));
80101599:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
8010159c:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
8010159e:	8d 40 5c             	lea    0x5c(%eax),%eax
801015a1:	6a 1c                	push   $0x1c
801015a3:	50                   	push   %eax
801015a4:	56                   	push   %esi
801015a5:	e8 16 33 00 00       	call   801048c0 <memmove>
  brelse(bp);
801015aa:	89 5d 08             	mov    %ebx,0x8(%ebp)
801015ad:	83 c4 10             	add    $0x10,%esp
}
801015b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
801015b3:	5b                   	pop    %ebx
801015b4:	5e                   	pop    %esi
801015b5:	5d                   	pop    %ebp
  brelse(bp);
801015b6:	e9 55 ec ff ff       	jmp    80100210 <brelse>
801015bb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801015bf:	90                   	nop

801015c0 <bfree>:
{
801015c0:	55                   	push   %ebp
801015c1:	89 e5                	mov    %esp,%ebp
801015c3:	56                   	push   %esi
801015c4:	89 c6                	mov    %eax,%esi
801015c6:	53                   	push   %ebx
801015c7:	89 d3                	mov    %edx,%ebx
  readsb(dev, &sb);
801015c9:	83 ec 08             	sub    $0x8,%esp
801015cc:	68 c0 19 11 80       	push   $0x801119c0
801015d1:	50                   	push   %eax
801015d2:	e8 a9 ff ff ff       	call   80101580 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
801015d7:	58                   	pop    %eax
801015d8:	89 d8                	mov    %ebx,%eax
801015da:	5a                   	pop    %edx
801015db:	c1 e8 0c             	shr    $0xc,%eax
801015de:	03 05 d8 19 11 80    	add    0x801119d8,%eax
801015e4:	50                   	push   %eax
801015e5:	56                   	push   %esi
801015e6:	e8 a5 eb ff ff       	call   80100190 <bread>
  m = 1 << (bi % 8);
801015eb:	89 d9                	mov    %ebx,%ecx
  if((bp->data[bi/8] & m) == 0)
801015ed:	c1 fb 03             	sar    $0x3,%ebx
  m = 1 << (bi % 8);
801015f0:	ba 01 00 00 00       	mov    $0x1,%edx
801015f5:	83 e1 07             	and    $0x7,%ecx
  if((bp->data[bi/8] & m) == 0)
801015f8:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801015fe:	83 c4 10             	add    $0x10,%esp
  m = 1 << (bi % 8);
80101601:	d3 e2                	shl    %cl,%edx
  if((bp->data[bi/8] & m) == 0)
80101603:	0f b6 4c 18 5c       	movzbl 0x5c(%eax,%ebx,1),%ecx
80101608:	85 d1                	test   %edx,%ecx
8010160a:	74 25                	je     80101631 <bfree+0x71>
  bp->data[bi/8] &= ~m;
8010160c:	f7 d2                	not    %edx
  bwrite(bp);
8010160e:	83 ec 0c             	sub    $0xc,%esp
80101611:	89 c6                	mov    %eax,%esi
  bp->data[bi/8] &= ~m;
80101613:	21 ca                	and    %ecx,%edx
80101615:	88 54 18 5c          	mov    %dl,0x5c(%eax,%ebx,1)
  bwrite(bp);
80101619:	50                   	push   %eax
8010161a:	e8 b1 eb ff ff       	call   801001d0 <bwrite>
  brelse(bp);
8010161f:	89 34 24             	mov    %esi,(%esp)
80101622:	e8 e9 eb ff ff       	call   80100210 <brelse>
}
80101627:	83 c4 10             	add    $0x10,%esp
8010162a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010162d:	5b                   	pop    %ebx
8010162e:	5e                   	pop    %esi
8010162f:	5d                   	pop    %ebp
80101630:	c3                   	ret    
    panic("freeing free block");
80101631:	83 ec 0c             	sub    $0xc,%esp
80101634:	68 38 7b 10 80       	push   $0x80107b38
80101639:	e8 42 ee ff ff       	call   80100480 <panic>
8010163e:	66 90                	xchg   %ax,%ax

80101640 <balloc_page>:
{
80101640:	f3 0f 1e fb          	endbr32 
80101644:	55                   	push   %ebp
80101645:	89 e5                	mov    %esp,%ebp
80101647:	57                   	push   %edi
80101648:	56                   	push   %esi
80101649:	53                   	push   %ebx
8010164a:	8d 84 24 00 f0 f9 ff 	lea    -0x61000(%esp),%eax
80101651:	81 ec 00 10 00 00    	sub    $0x1000,%esp
80101657:	83 0c 24 00          	orl    $0x0,(%esp)
8010165b:	39 c4                	cmp    %eax,%esp
8010165d:	75 f2                	jne    80101651 <balloc_page+0x11>
8010165f:	81 ec 8c 0a 00 00    	sub    $0xa8c,%esp
  for(int i=0;i<8;i++){
80101665:	31 f6                	xor    %esi,%esi
  int indexNCB=-1;     //pointer for above array, keeps track till where it is filled
80101667:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010166c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      allocatedBlocks[indexNCB] = balloc(dev);  // low l2et mkan mosh m3molh alloc b3mloh alloc w elmra ally b3dha mosh hyzhrly f h3ml lly b3do
80101670:	8b 45 08             	mov    0x8(%ebp),%eax
      indexNCB++;
80101673:	8d 5f 01             	lea    0x1(%edi),%ebx
      allocatedBlocks[indexNCB] = balloc(dev);  // low l2et mkan mosh m3molh alloc b3mloh alloc w elmra ally b3dha mosh hyzhrly f h3ml lly b3do
80101676:	e8 25 fc ff ff       	call   801012a0 <balloc>
8010167b:	89 84 9d 68 e5 f9 ff 	mov    %eax,-0x61a98(%ebp,%ebx,4)
      if(i>0){    // 3shan a3rf a3ml compare m3 mkan ally 2blo
80101682:	85 f6                	test   %esi,%esi
80101684:	74 0c                	je     80101692 <balloc_page+0x52>
          if((allocatedBlocks[indexNCB]-allocatedBlocks[indexNCB-1])!=1)  //this allocated block in non consecutive // hna lazm a3ml l 8 wra b3d
80101686:	2b 84 9d 64 e5 f9 ff 	sub    -0x61a9c(%ebp,%ebx,4),%eax
8010168d:	83 f8 01             	cmp    $0x1,%eax
80101690:	74 0e                	je     801016a0 <balloc_page+0x60>
  for(int i=0;i<8;i++){
80101692:	be 01 00 00 00       	mov    $0x1,%esi
      indexNCB++;
80101697:	89 df                	mov    %ebx,%edi
80101699:	eb d5                	jmp    80101670 <balloc_page+0x30>
8010169b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010169f:	90                   	nop
  for(int i=0;i<8;i++){
801016a0:	83 c6 01             	add    $0x1,%esi
801016a3:	83 fe 08             	cmp    $0x8,%esi
801016a6:	75 ef                	jne    80101697 <balloc_page+0x57>
    for(int i=0;i<=indexNCB-8;i++){      // hna b3d mal2et 8 wra b3d ana kont 3aml alloc zyada l7d mal2et el 8 f h3ml free l kolo l7d awl block ana m7tago
801016a8:	8d 77 fa             	lea    -0x6(%edi),%esi
801016ab:	85 f6                	test   %esi,%esi
801016ad:	7e 24                	jle    801016d3 <balloc_page+0x93>
801016af:	8d 9d 68 e5 f9 ff    	lea    -0x61a98(%ebp),%ebx
801016b5:	8d bc bd 50 e5 f9 ff 	lea    -0x61ab0(%ebp,%edi,4),%edi
801016bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      bfree(ROOTDEV,allocatedBlocks[i]);    //free unnecesarily allocated blocks
801016c0:	8b 13                	mov    (%ebx),%edx
801016c2:	b8 01 00 00 00       	mov    $0x1,%eax
801016c7:	83 c3 04             	add    $0x4,%ebx
801016ca:	e8 f1 fe ff ff       	call   801015c0 <bfree>
    for(int i=0;i<=indexNCB-8;i++){      // hna b3d mal2et 8 wra b3d ana kont 3aml alloc zyada l7d mal2et el 8 f h3ml free l kolo l7d awl block ana m7tago
801016cf:	39 fb                	cmp    %edi,%ebx
801016d1:	75 ed                	jne    801016c0 <balloc_page+0x80>
	  return allocatedBlocks[indexNCB-7];  //return last 8 blocks (address of 1st block among them)  // hna barg3 awl mkaan fe el 8
801016d3:	8b 84 b5 68 e5 f9 ff 	mov    -0x61a98(%ebp,%esi,4),%eax
    numallocblocks+=1;      //*****************   //  de t2rebn no of pages ally 3mltlha alloc fe disk
801016da:	83 05 5c b5 10 80 01 	addl   $0x1,0x8010b55c
}
801016e1:	81 c4 8c 1a 06 00    	add    $0x61a8c,%esp
801016e7:	5b                   	pop    %ebx
801016e8:	5e                   	pop    %esi
801016e9:	5f                   	pop    %edi
801016ea:	5d                   	pop    %ebp
801016eb:	c3                   	ret    
801016ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801016f0 <bfree_page>:
{ //*******************xv7*****************
801016f0:	f3 0f 1e fb          	endbr32 
801016f4:	55                   	push   %ebp
801016f5:	89 e5                	mov    %esp,%ebp
801016f7:	56                   	push   %esi
801016f8:	53                   	push   %ebx
801016f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801016fc:	8d 73 08             	lea    0x8(%ebx),%esi
801016ff:	90                   	nop
    bfree(ROOTDEV,b+i);   // hna blf 3lehom kol wa7da
80101700:	89 da                	mov    %ebx,%edx
80101702:	b8 01 00 00 00       	mov    $0x1,%eax
80101707:	83 c3 01             	add    $0x1,%ebx
8010170a:	e8 b1 fe ff ff       	call   801015c0 <bfree>
  for(uint i=0;i<8;i++){
8010170f:	39 de                	cmp    %ebx,%esi
80101711:	75 ed                	jne    80101700 <bfree_page+0x10>
}
80101713:	5b                   	pop    %ebx
  numallocblocks-=1;      //*****************  // hna bn2s no of pages ally 3mltlha alloc fe disk
80101714:	83 2d 5c b5 10 80 01 	subl   $0x1,0x8010b55c
}
8010171b:	5e                   	pop    %esi
8010171c:	5d                   	pop    %ebp
8010171d:	c3                   	ret    
8010171e:	66 90                	xchg   %ax,%ax

80101720 <iinit>:
{
80101720:	f3 0f 1e fb          	endbr32 
80101724:	55                   	push   %ebp
80101725:	89 e5                	mov    %esp,%ebp
80101727:	53                   	push   %ebx
80101728:	bb 20 1a 11 80       	mov    $0x80111a20,%ebx
8010172d:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
80101730:	68 4b 7b 10 80       	push   $0x80107b4b
80101735:	68 e0 19 11 80       	push   $0x801119e0
8010173a:	e8 51 2e 00 00       	call   80104590 <initlock>
  for(i = 0; i < NINODE; i++) {
8010173f:	83 c4 10             	add    $0x10,%esp
80101742:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    initsleeplock(&icache.inode[i].lock, "inode");
80101748:	83 ec 08             	sub    $0x8,%esp
8010174b:	68 52 7b 10 80       	push   $0x80107b52
80101750:	53                   	push   %ebx
80101751:	81 c3 90 00 00 00    	add    $0x90,%ebx
80101757:	e8 24 2d 00 00       	call   80104480 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
8010175c:	83 c4 10             	add    $0x10,%esp
8010175f:	81 fb 40 36 11 80    	cmp    $0x80113640,%ebx
80101765:	75 e1                	jne    80101748 <iinit+0x28>
  readsb(dev, &sb);
80101767:	83 ec 08             	sub    $0x8,%esp
8010176a:	68 c0 19 11 80       	push   $0x801119c0
8010176f:	ff 75 08             	pushl  0x8(%ebp)
80101772:	e8 09 fe ff ff       	call   80101580 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101777:	ff 35 d8 19 11 80    	pushl  0x801119d8
8010177d:	ff 35 d4 19 11 80    	pushl  0x801119d4
80101783:	ff 35 d0 19 11 80    	pushl  0x801119d0
80101789:	ff 35 cc 19 11 80    	pushl  0x801119cc
8010178f:	ff 35 c8 19 11 80    	pushl  0x801119c8
80101795:	ff 35 c4 19 11 80    	pushl  0x801119c4
8010179b:	ff 35 c0 19 11 80    	pushl  0x801119c0
801017a1:	68 b8 7b 10 80       	push   $0x80107bb8
801017a6:	e8 f5 ef ff ff       	call   801007a0 <cprintf>
}
801017ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801017ae:	83 c4 30             	add    $0x30,%esp
801017b1:	c9                   	leave  
801017b2:	c3                   	ret    
801017b3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801017ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801017c0 <ialloc>:
{
801017c0:	f3 0f 1e fb          	endbr32 
801017c4:	55                   	push   %ebp
801017c5:	89 e5                	mov    %esp,%ebp
801017c7:	57                   	push   %edi
801017c8:	56                   	push   %esi
801017c9:	53                   	push   %ebx
801017ca:	83 ec 1c             	sub    $0x1c,%esp
801017cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  for(inum = 1; inum < sb.ninodes; inum++){
801017d0:	83 3d c8 19 11 80 01 	cmpl   $0x1,0x801119c8
{
801017d7:	8b 75 08             	mov    0x8(%ebp),%esi
801017da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
801017dd:	0f 86 8d 00 00 00    	jbe    80101870 <ialloc+0xb0>
801017e3:	bf 01 00 00 00       	mov    $0x1,%edi
801017e8:	eb 1d                	jmp    80101807 <ialloc+0x47>
801017ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    brelse(bp);
801017f0:	83 ec 0c             	sub    $0xc,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017f3:	83 c7 01             	add    $0x1,%edi
    brelse(bp);
801017f6:	53                   	push   %ebx
801017f7:	e8 14 ea ff ff       	call   80100210 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
801017fc:	83 c4 10             	add    $0x10,%esp
801017ff:	3b 3d c8 19 11 80    	cmp    0x801119c8,%edi
80101805:	73 69                	jae    80101870 <ialloc+0xb0>
    bp = bread(dev, IBLOCK(inum, sb));
80101807:	89 f8                	mov    %edi,%eax
80101809:	83 ec 08             	sub    $0x8,%esp
8010180c:	c1 e8 03             	shr    $0x3,%eax
8010180f:	03 05 d4 19 11 80    	add    0x801119d4,%eax
80101815:	50                   	push   %eax
80101816:	56                   	push   %esi
80101817:	e8 74 e9 ff ff       	call   80100190 <bread>
    if(dip->type == 0){  // a free inode
8010181c:	83 c4 10             	add    $0x10,%esp
    bp = bread(dev, IBLOCK(inum, sb));
8010181f:	89 c3                	mov    %eax,%ebx
    dip = (struct dinode*)bp->data + inum%IPB;
80101821:	89 f8                	mov    %edi,%eax
80101823:	83 e0 07             	and    $0x7,%eax
80101826:	c1 e0 06             	shl    $0x6,%eax
80101829:	8d 4c 03 5c          	lea    0x5c(%ebx,%eax,1),%ecx
    if(dip->type == 0){  // a free inode
8010182d:	66 83 39 00          	cmpw   $0x0,(%ecx)
80101831:	75 bd                	jne    801017f0 <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
80101833:	83 ec 04             	sub    $0x4,%esp
80101836:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80101839:	6a 40                	push   $0x40
8010183b:	6a 00                	push   $0x0
8010183d:	51                   	push   %ecx
8010183e:	e8 dd 2f 00 00       	call   80104820 <memset>
      dip->type = type;
80101843:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80101847:	8b 4d e0             	mov    -0x20(%ebp),%ecx
8010184a:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
8010184d:	89 1c 24             	mov    %ebx,(%esp)
80101850:	e8 8b 18 00 00       	call   801030e0 <log_write>
      brelse(bp);
80101855:	89 1c 24             	mov    %ebx,(%esp)
80101858:	e8 b3 e9 ff ff       	call   80100210 <brelse>
      return iget(dev, inum);
8010185d:	83 c4 10             	add    $0x10,%esp
}
80101860:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return iget(dev, inum);
80101863:	89 fa                	mov    %edi,%edx
}
80101865:	5b                   	pop    %ebx
      return iget(dev, inum);
80101866:	89 f0                	mov    %esi,%eax
}
80101868:	5e                   	pop    %esi
80101869:	5f                   	pop    %edi
8010186a:	5d                   	pop    %ebp
      return iget(dev, inum);
8010186b:	e9 50 fb ff ff       	jmp    801013c0 <iget>
  panic("ialloc: no inodes");
80101870:	83 ec 0c             	sub    $0xc,%esp
80101873:	68 58 7b 10 80       	push   $0x80107b58
80101878:	e8 03 ec ff ff       	call   80100480 <panic>
8010187d:	8d 76 00             	lea    0x0(%esi),%esi

80101880 <iupdate>:
{
80101880:	f3 0f 1e fb          	endbr32 
80101884:	55                   	push   %ebp
80101885:	89 e5                	mov    %esp,%ebp
80101887:	56                   	push   %esi
80101888:	53                   	push   %ebx
80101889:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010188c:	8b 43 04             	mov    0x4(%ebx),%eax
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010188f:	83 c3 5c             	add    $0x5c,%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101892:	83 ec 08             	sub    $0x8,%esp
80101895:	c1 e8 03             	shr    $0x3,%eax
80101898:	03 05 d4 19 11 80    	add    0x801119d4,%eax
8010189e:	50                   	push   %eax
8010189f:	ff 73 a4             	pushl  -0x5c(%ebx)
801018a2:	e8 e9 e8 ff ff       	call   80100190 <bread>
  dip->type = ip->type;
801018a7:	0f b7 53 f4          	movzwl -0xc(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018ab:	83 c4 0c             	add    $0xc,%esp
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018ae:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801018b0:	8b 43 a8             	mov    -0x58(%ebx),%eax
801018b3:	83 e0 07             	and    $0x7,%eax
801018b6:	c1 e0 06             	shl    $0x6,%eax
801018b9:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
801018bd:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801018c0:	0f b7 53 f6          	movzwl -0xa(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018c4:	83 c0 0c             	add    $0xc,%eax
  dip->major = ip->major;
801018c7:	66 89 50 f6          	mov    %dx,-0xa(%eax)
  dip->minor = ip->minor;
801018cb:	0f b7 53 f8          	movzwl -0x8(%ebx),%edx
801018cf:	66 89 50 f8          	mov    %dx,-0x8(%eax)
  dip->nlink = ip->nlink;
801018d3:	0f b7 53 fa          	movzwl -0x6(%ebx),%edx
801018d7:	66 89 50 fa          	mov    %dx,-0x6(%eax)
  dip->size = ip->size;
801018db:	8b 53 fc             	mov    -0x4(%ebx),%edx
801018de:	89 50 fc             	mov    %edx,-0x4(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018e1:	6a 34                	push   $0x34
801018e3:	53                   	push   %ebx
801018e4:	50                   	push   %eax
801018e5:	e8 d6 2f 00 00       	call   801048c0 <memmove>
  log_write(bp);
801018ea:	89 34 24             	mov    %esi,(%esp)
801018ed:	e8 ee 17 00 00       	call   801030e0 <log_write>
  brelse(bp);
801018f2:	89 75 08             	mov    %esi,0x8(%ebp)
801018f5:	83 c4 10             	add    $0x10,%esp
}
801018f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801018fb:	5b                   	pop    %ebx
801018fc:	5e                   	pop    %esi
801018fd:	5d                   	pop    %ebp
  brelse(bp);
801018fe:	e9 0d e9 ff ff       	jmp    80100210 <brelse>
80101903:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010190a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101910 <idup>:
{
80101910:	f3 0f 1e fb          	endbr32 
80101914:	55                   	push   %ebp
80101915:	89 e5                	mov    %esp,%ebp
80101917:	53                   	push   %ebx
80101918:	83 ec 10             	sub    $0x10,%esp
8010191b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
8010191e:	68 e0 19 11 80       	push   $0x801119e0
80101923:	e8 78 2d 00 00       	call   801046a0 <acquire>
  ip->ref++;
80101928:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
8010192c:	c7 04 24 e0 19 11 80 	movl   $0x801119e0,(%esp)
80101933:	e8 98 2e 00 00       	call   801047d0 <release>
}
80101938:	89 d8                	mov    %ebx,%eax
8010193a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010193d:	c9                   	leave  
8010193e:	c3                   	ret    
8010193f:	90                   	nop

80101940 <ilock>:
{
80101940:	f3 0f 1e fb          	endbr32 
80101944:	55                   	push   %ebp
80101945:	89 e5                	mov    %esp,%ebp
80101947:	56                   	push   %esi
80101948:	53                   	push   %ebx
80101949:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
8010194c:	85 db                	test   %ebx,%ebx
8010194e:	0f 84 b3 00 00 00    	je     80101a07 <ilock+0xc7>
80101954:	8b 53 08             	mov    0x8(%ebx),%edx
80101957:	85 d2                	test   %edx,%edx
80101959:	0f 8e a8 00 00 00    	jle    80101a07 <ilock+0xc7>
  acquiresleep(&ip->lock);
8010195f:	83 ec 0c             	sub    $0xc,%esp
80101962:	8d 43 0c             	lea    0xc(%ebx),%eax
80101965:	50                   	push   %eax
80101966:	e8 55 2b 00 00       	call   801044c0 <acquiresleep>
  if(ip->valid == 0){
8010196b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010196e:	83 c4 10             	add    $0x10,%esp
80101971:	85 c0                	test   %eax,%eax
80101973:	74 0b                	je     80101980 <ilock+0x40>
}
80101975:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101978:	5b                   	pop    %ebx
80101979:	5e                   	pop    %esi
8010197a:	5d                   	pop    %ebp
8010197b:	c3                   	ret    
8010197c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101980:	8b 43 04             	mov    0x4(%ebx),%eax
80101983:	83 ec 08             	sub    $0x8,%esp
80101986:	c1 e8 03             	shr    $0x3,%eax
80101989:	03 05 d4 19 11 80    	add    0x801119d4,%eax
8010198f:	50                   	push   %eax
80101990:	ff 33                	pushl  (%ebx)
80101992:	e8 f9 e7 ff ff       	call   80100190 <bread>
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101997:	83 c4 0c             	add    $0xc,%esp
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010199a:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
8010199c:	8b 43 04             	mov    0x4(%ebx),%eax
8010199f:	83 e0 07             	and    $0x7,%eax
801019a2:	c1 e0 06             	shl    $0x6,%eax
801019a5:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
801019a9:	0f b7 10             	movzwl (%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801019ac:	83 c0 0c             	add    $0xc,%eax
    ip->type = dip->type;
801019af:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
801019b3:	0f b7 50 f6          	movzwl -0xa(%eax),%edx
801019b7:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
801019bb:	0f b7 50 f8          	movzwl -0x8(%eax),%edx
801019bf:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
801019c3:	0f b7 50 fa          	movzwl -0x6(%eax),%edx
801019c7:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
801019cb:	8b 50 fc             	mov    -0x4(%eax),%edx
801019ce:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801019d1:	6a 34                	push   $0x34
801019d3:	50                   	push   %eax
801019d4:	8d 43 5c             	lea    0x5c(%ebx),%eax
801019d7:	50                   	push   %eax
801019d8:	e8 e3 2e 00 00       	call   801048c0 <memmove>
    brelse(bp);
801019dd:	89 34 24             	mov    %esi,(%esp)
801019e0:	e8 2b e8 ff ff       	call   80100210 <brelse>
    if(ip->type == 0)
801019e5:	83 c4 10             	add    $0x10,%esp
801019e8:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
    ip->valid = 1;
801019ed:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
801019f4:	0f 85 7b ff ff ff    	jne    80101975 <ilock+0x35>
      panic("ilock: no type");
801019fa:	83 ec 0c             	sub    $0xc,%esp
801019fd:	68 70 7b 10 80       	push   $0x80107b70
80101a02:	e8 79 ea ff ff       	call   80100480 <panic>
    panic("ilock");
80101a07:	83 ec 0c             	sub    $0xc,%esp
80101a0a:	68 6a 7b 10 80       	push   $0x80107b6a
80101a0f:	e8 6c ea ff ff       	call   80100480 <panic>
80101a14:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101a1b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101a1f:	90                   	nop

80101a20 <iunlock>:
{
80101a20:	f3 0f 1e fb          	endbr32 
80101a24:	55                   	push   %ebp
80101a25:	89 e5                	mov    %esp,%ebp
80101a27:	56                   	push   %esi
80101a28:	53                   	push   %ebx
80101a29:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101a2c:	85 db                	test   %ebx,%ebx
80101a2e:	74 28                	je     80101a58 <iunlock+0x38>
80101a30:	83 ec 0c             	sub    $0xc,%esp
80101a33:	8d 73 0c             	lea    0xc(%ebx),%esi
80101a36:	56                   	push   %esi
80101a37:	e8 24 2b 00 00       	call   80104560 <holdingsleep>
80101a3c:	83 c4 10             	add    $0x10,%esp
80101a3f:	85 c0                	test   %eax,%eax
80101a41:	74 15                	je     80101a58 <iunlock+0x38>
80101a43:	8b 43 08             	mov    0x8(%ebx),%eax
80101a46:	85 c0                	test   %eax,%eax
80101a48:	7e 0e                	jle    80101a58 <iunlock+0x38>
  releasesleep(&ip->lock);
80101a4a:	89 75 08             	mov    %esi,0x8(%ebp)
}
80101a4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101a50:	5b                   	pop    %ebx
80101a51:	5e                   	pop    %esi
80101a52:	5d                   	pop    %ebp
  releasesleep(&ip->lock);
80101a53:	e9 c8 2a 00 00       	jmp    80104520 <releasesleep>
    panic("iunlock");
80101a58:	83 ec 0c             	sub    $0xc,%esp
80101a5b:	68 7f 7b 10 80       	push   $0x80107b7f
80101a60:	e8 1b ea ff ff       	call   80100480 <panic>
80101a65:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101a6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101a70 <iput>:
{
80101a70:	f3 0f 1e fb          	endbr32 
80101a74:	55                   	push   %ebp
80101a75:	89 e5                	mov    %esp,%ebp
80101a77:	57                   	push   %edi
80101a78:	56                   	push   %esi
80101a79:	53                   	push   %ebx
80101a7a:	83 ec 28             	sub    $0x28,%esp
80101a7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
80101a80:	8d 7b 0c             	lea    0xc(%ebx),%edi
80101a83:	57                   	push   %edi
80101a84:	e8 37 2a 00 00       	call   801044c0 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101a89:	8b 53 4c             	mov    0x4c(%ebx),%edx
80101a8c:	83 c4 10             	add    $0x10,%esp
80101a8f:	85 d2                	test   %edx,%edx
80101a91:	74 07                	je     80101a9a <iput+0x2a>
80101a93:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101a98:	74 36                	je     80101ad0 <iput+0x60>
  releasesleep(&ip->lock);
80101a9a:	83 ec 0c             	sub    $0xc,%esp
80101a9d:	57                   	push   %edi
80101a9e:	e8 7d 2a 00 00       	call   80104520 <releasesleep>
  acquire(&icache.lock);
80101aa3:	c7 04 24 e0 19 11 80 	movl   $0x801119e0,(%esp)
80101aaa:	e8 f1 2b 00 00       	call   801046a0 <acquire>
  ip->ref--;
80101aaf:	83 6b 08 01          	subl   $0x1,0x8(%ebx)
  release(&icache.lock);
80101ab3:	83 c4 10             	add    $0x10,%esp
80101ab6:	c7 45 08 e0 19 11 80 	movl   $0x801119e0,0x8(%ebp)
}
80101abd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101ac0:	5b                   	pop    %ebx
80101ac1:	5e                   	pop    %esi
80101ac2:	5f                   	pop    %edi
80101ac3:	5d                   	pop    %ebp
  release(&icache.lock);
80101ac4:	e9 07 2d 00 00       	jmp    801047d0 <release>
80101ac9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    acquire(&icache.lock);
80101ad0:	83 ec 0c             	sub    $0xc,%esp
80101ad3:	68 e0 19 11 80       	push   $0x801119e0
80101ad8:	e8 c3 2b 00 00       	call   801046a0 <acquire>
    int r = ip->ref;
80101add:	8b 73 08             	mov    0x8(%ebx),%esi
    release(&icache.lock);
80101ae0:	c7 04 24 e0 19 11 80 	movl   $0x801119e0,(%esp)
80101ae7:	e8 e4 2c 00 00       	call   801047d0 <release>
    if(r == 1){
80101aec:	83 c4 10             	add    $0x10,%esp
80101aef:	83 fe 01             	cmp    $0x1,%esi
80101af2:	75 a6                	jne    80101a9a <iput+0x2a>
80101af4:	8d 8b 8c 00 00 00    	lea    0x8c(%ebx),%ecx
80101afa:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80101afd:	8d 73 5c             	lea    0x5c(%ebx),%esi
80101b00:	89 cf                	mov    %ecx,%edi
80101b02:	eb 0b                	jmp    80101b0f <iput+0x9f>
80101b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101b08:	83 c6 04             	add    $0x4,%esi
80101b0b:	39 fe                	cmp    %edi,%esi
80101b0d:	74 19                	je     80101b28 <iput+0xb8>
    if(ip->addrs[i]){
80101b0f:	8b 16                	mov    (%esi),%edx
80101b11:	85 d2                	test   %edx,%edx
80101b13:	74 f3                	je     80101b08 <iput+0x98>
      bfree(ip->dev, ip->addrs[i]);
80101b15:	8b 03                	mov    (%ebx),%eax
80101b17:	e8 a4 fa ff ff       	call   801015c0 <bfree>
      ip->addrs[i] = 0;
80101b1c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80101b22:	eb e4                	jmp    80101b08 <iput+0x98>
80101b24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
  }

  if(ip->addrs[NDIRECT]){
80101b28:	8b 83 8c 00 00 00    	mov    0x8c(%ebx),%eax
80101b2e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101b31:	85 c0                	test   %eax,%eax
80101b33:	75 33                	jne    80101b68 <iput+0xf8>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  iupdate(ip);
80101b35:	83 ec 0c             	sub    $0xc,%esp
  ip->size = 0;
80101b38:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  iupdate(ip);
80101b3f:	53                   	push   %ebx
80101b40:	e8 3b fd ff ff       	call   80101880 <iupdate>
      ip->type = 0;
80101b45:	31 c0                	xor    %eax,%eax
80101b47:	66 89 43 50          	mov    %ax,0x50(%ebx)
      iupdate(ip);
80101b4b:	89 1c 24             	mov    %ebx,(%esp)
80101b4e:	e8 2d fd ff ff       	call   80101880 <iupdate>
      ip->valid = 0;
80101b53:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101b5a:	83 c4 10             	add    $0x10,%esp
80101b5d:	e9 38 ff ff ff       	jmp    80101a9a <iput+0x2a>
80101b62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101b68:	83 ec 08             	sub    $0x8,%esp
80101b6b:	50                   	push   %eax
80101b6c:	ff 33                	pushl  (%ebx)
80101b6e:	e8 1d e6 ff ff       	call   80100190 <bread>
80101b73:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101b76:	83 c4 10             	add    $0x10,%esp
80101b79:	8d 88 5c 02 00 00    	lea    0x25c(%eax),%ecx
80101b7f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101b82:	8d 70 5c             	lea    0x5c(%eax),%esi
80101b85:	89 cf                	mov    %ecx,%edi
80101b87:	eb 0e                	jmp    80101b97 <iput+0x127>
80101b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101b90:	83 c6 04             	add    $0x4,%esi
80101b93:	39 f7                	cmp    %esi,%edi
80101b95:	74 19                	je     80101bb0 <iput+0x140>
      if(a[j])
80101b97:	8b 16                	mov    (%esi),%edx
80101b99:	85 d2                	test   %edx,%edx
80101b9b:	74 f3                	je     80101b90 <iput+0x120>
        bfree(ip->dev, a[j]);
80101b9d:	8b 03                	mov    (%ebx),%eax
80101b9f:	e8 1c fa ff ff       	call   801015c0 <bfree>
80101ba4:	eb ea                	jmp    80101b90 <iput+0x120>
80101ba6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101bad:	8d 76 00             	lea    0x0(%esi),%esi
    brelse(bp);
80101bb0:	83 ec 0c             	sub    $0xc,%esp
80101bb3:	ff 75 e4             	pushl  -0x1c(%ebp)
80101bb6:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101bb9:	e8 52 e6 ff ff       	call   80100210 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101bbe:	8b 93 8c 00 00 00    	mov    0x8c(%ebx),%edx
80101bc4:	8b 03                	mov    (%ebx),%eax
80101bc6:	e8 f5 f9 ff ff       	call   801015c0 <bfree>
    ip->addrs[NDIRECT] = 0;
80101bcb:	83 c4 10             	add    $0x10,%esp
80101bce:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
80101bd5:	00 00 00 
80101bd8:	e9 58 ff ff ff       	jmp    80101b35 <iput+0xc5>
80101bdd:	8d 76 00             	lea    0x0(%esi),%esi

80101be0 <iunlockput>:
{
80101be0:	f3 0f 1e fb          	endbr32 
80101be4:	55                   	push   %ebp
80101be5:	89 e5                	mov    %esp,%ebp
80101be7:	53                   	push   %ebx
80101be8:	83 ec 10             	sub    $0x10,%esp
80101beb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
80101bee:	53                   	push   %ebx
80101bef:	e8 2c fe ff ff       	call   80101a20 <iunlock>
  iput(ip);
80101bf4:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101bf7:	83 c4 10             	add    $0x10,%esp
}
80101bfa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101bfd:	c9                   	leave  
  iput(ip);
80101bfe:	e9 6d fe ff ff       	jmp    80101a70 <iput>
80101c03:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101c0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101c10 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101c10:	f3 0f 1e fb          	endbr32 
80101c14:	55                   	push   %ebp
80101c15:	89 e5                	mov    %esp,%ebp
80101c17:	8b 55 08             	mov    0x8(%ebp),%edx
80101c1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101c1d:	8b 0a                	mov    (%edx),%ecx
80101c1f:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101c22:	8b 4a 04             	mov    0x4(%edx),%ecx
80101c25:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101c28:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101c2c:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101c2f:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101c33:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101c37:	8b 52 58             	mov    0x58(%edx),%edx
80101c3a:	89 50 10             	mov    %edx,0x10(%eax)
}
80101c3d:	5d                   	pop    %ebp
80101c3e:	c3                   	ret    
80101c3f:	90                   	nop

80101c40 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101c40:	f3 0f 1e fb          	endbr32 
80101c44:	55                   	push   %ebp
80101c45:	89 e5                	mov    %esp,%ebp
80101c47:	57                   	push   %edi
80101c48:	56                   	push   %esi
80101c49:	53                   	push   %ebx
80101c4a:	83 ec 1c             	sub    $0x1c,%esp
80101c4d:	8b 7d 0c             	mov    0xc(%ebp),%edi
80101c50:	8b 45 08             	mov    0x8(%ebp),%eax
80101c53:	8b 75 10             	mov    0x10(%ebp),%esi
80101c56:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101c59:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101c5c:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101c61:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101c64:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  if(ip->type == T_DEV){
80101c67:	0f 84 a3 00 00 00    	je     80101d10 <readi+0xd0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
80101c6d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101c70:	8b 40 58             	mov    0x58(%eax),%eax
80101c73:	39 c6                	cmp    %eax,%esi
80101c75:	0f 87 b6 00 00 00    	ja     80101d31 <readi+0xf1>
80101c7b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101c7e:	31 c9                	xor    %ecx,%ecx
80101c80:	89 da                	mov    %ebx,%edx
80101c82:	01 f2                	add    %esi,%edx
80101c84:	0f 92 c1             	setb   %cl
80101c87:	89 cf                	mov    %ecx,%edi
80101c89:	0f 82 a2 00 00 00    	jb     80101d31 <readi+0xf1>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101c8f:	89 c1                	mov    %eax,%ecx
80101c91:	29 f1                	sub    %esi,%ecx
80101c93:	39 d0                	cmp    %edx,%eax
80101c95:	0f 43 cb             	cmovae %ebx,%ecx
80101c98:	89 4d e4             	mov    %ecx,-0x1c(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101c9b:	85 c9                	test   %ecx,%ecx
80101c9d:	74 63                	je     80101d02 <readi+0xc2>
80101c9f:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101ca0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
80101ca3:	89 f2                	mov    %esi,%edx
80101ca5:	c1 ea 09             	shr    $0x9,%edx
80101ca8:	89 d8                	mov    %ebx,%eax
80101caa:	e8 01 f8 ff ff       	call   801014b0 <bmap>
80101caf:	83 ec 08             	sub    $0x8,%esp
80101cb2:	50                   	push   %eax
80101cb3:	ff 33                	pushl  (%ebx)
80101cb5:	e8 d6 e4 ff ff       	call   80100190 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101cba:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101cbd:	b9 00 02 00 00       	mov    $0x200,%ecx
80101cc2:	83 c4 0c             	add    $0xc,%esp
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101cc5:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101cc7:	89 f0                	mov    %esi,%eax
80101cc9:	25 ff 01 00 00       	and    $0x1ff,%eax
80101cce:	29 fb                	sub    %edi,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101cd0:	89 55 dc             	mov    %edx,-0x24(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101cd3:	29 c1                	sub    %eax,%ecx
    memmove(dst, bp->data + off%BSIZE, m);
80101cd5:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101cd9:	39 d9                	cmp    %ebx,%ecx
80101cdb:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101cde:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101cdf:	01 df                	add    %ebx,%edi
80101ce1:	01 de                	add    %ebx,%esi
    memmove(dst, bp->data + off%BSIZE, m);
80101ce3:	50                   	push   %eax
80101ce4:	ff 75 e0             	pushl  -0x20(%ebp)
80101ce7:	e8 d4 2b 00 00       	call   801048c0 <memmove>
    brelse(bp);
80101cec:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101cef:	89 14 24             	mov    %edx,(%esp)
80101cf2:	e8 19 e5 ff ff       	call   80100210 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101cf7:	01 5d e0             	add    %ebx,-0x20(%ebp)
80101cfa:	83 c4 10             	add    $0x10,%esp
80101cfd:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80101d00:	77 9e                	ja     80101ca0 <readi+0x60>
  }
  return n;
80101d02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80101d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101d08:	5b                   	pop    %ebx
80101d09:	5e                   	pop    %esi
80101d0a:	5f                   	pop    %edi
80101d0b:	5d                   	pop    %ebp
80101d0c:	c3                   	ret    
80101d0d:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101d10:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101d14:	66 83 f8 09          	cmp    $0x9,%ax
80101d18:	77 17                	ja     80101d31 <readi+0xf1>
80101d1a:	8b 04 c5 60 19 11 80 	mov    -0x7feee6a0(,%eax,8),%eax
80101d21:	85 c0                	test   %eax,%eax
80101d23:	74 0c                	je     80101d31 <readi+0xf1>
    return devsw[ip->major].read(ip, dst, n);
80101d25:	89 7d 10             	mov    %edi,0x10(%ebp)
}
80101d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101d2b:	5b                   	pop    %ebx
80101d2c:	5e                   	pop    %esi
80101d2d:	5f                   	pop    %edi
80101d2e:	5d                   	pop    %ebp
    return devsw[ip->major].read(ip, dst, n);
80101d2f:	ff e0                	jmp    *%eax
      return -1;
80101d31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101d36:	eb cd                	jmp    80101d05 <readi+0xc5>
80101d38:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101d3f:	90                   	nop

80101d40 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101d40:	f3 0f 1e fb          	endbr32 
80101d44:	55                   	push   %ebp
80101d45:	89 e5                	mov    %esp,%ebp
80101d47:	57                   	push   %edi
80101d48:	56                   	push   %esi
80101d49:	53                   	push   %ebx
80101d4a:	83 ec 1c             	sub    $0x1c,%esp
80101d4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d50:	8b 75 0c             	mov    0xc(%ebp),%esi
80101d53:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101d56:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101d5b:	89 75 dc             	mov    %esi,-0x24(%ebp)
80101d5e:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101d61:	8b 75 10             	mov    0x10(%ebp),%esi
80101d64:	89 7d e0             	mov    %edi,-0x20(%ebp)
  if(ip->type == T_DEV){
80101d67:	0f 84 b3 00 00 00    	je     80101e20 <writei+0xe0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
80101d6d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101d70:	39 70 58             	cmp    %esi,0x58(%eax)
80101d73:	0f 82 e3 00 00 00    	jb     80101e5c <writei+0x11c>
    return -1;
  if(off + n > MAXFILE*BSIZE)
80101d79:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101d7c:	89 f8                	mov    %edi,%eax
80101d7e:	01 f0                	add    %esi,%eax
80101d80:	0f 82 d6 00 00 00    	jb     80101e5c <writei+0x11c>
80101d86:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101d8b:	0f 87 cb 00 00 00    	ja     80101e5c <writei+0x11c>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101d91:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101d98:	85 ff                	test   %edi,%edi
80101d9a:	74 75                	je     80101e11 <writei+0xd1>
80101d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101da0:	8b 7d d8             	mov    -0x28(%ebp),%edi
80101da3:	89 f2                	mov    %esi,%edx
80101da5:	c1 ea 09             	shr    $0x9,%edx
80101da8:	89 f8                	mov    %edi,%eax
80101daa:	e8 01 f7 ff ff       	call   801014b0 <bmap>
80101daf:	83 ec 08             	sub    $0x8,%esp
80101db2:	50                   	push   %eax
80101db3:	ff 37                	pushl  (%edi)
80101db5:	e8 d6 e3 ff ff       	call   80100190 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101dba:	b9 00 02 00 00       	mov    $0x200,%ecx
80101dbf:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101dc2:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101dc5:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101dc7:	89 f0                	mov    %esi,%eax
80101dc9:	83 c4 0c             	add    $0xc,%esp
80101dcc:	25 ff 01 00 00       	and    $0x1ff,%eax
80101dd1:	29 c1                	sub    %eax,%ecx
    memmove(bp->data + off%BSIZE, src, m);
80101dd3:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101dd7:	39 d9                	cmp    %ebx,%ecx
80101dd9:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101ddc:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101ddd:	01 de                	add    %ebx,%esi
    memmove(bp->data + off%BSIZE, src, m);
80101ddf:	ff 75 dc             	pushl  -0x24(%ebp)
80101de2:	50                   	push   %eax
80101de3:	e8 d8 2a 00 00       	call   801048c0 <memmove>
    log_write(bp);
80101de8:	89 3c 24             	mov    %edi,(%esp)
80101deb:	e8 f0 12 00 00       	call   801030e0 <log_write>
    brelse(bp);
80101df0:	89 3c 24             	mov    %edi,(%esp)
80101df3:	e8 18 e4 ff ff       	call   80100210 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101df8:	01 5d e4             	add    %ebx,-0x1c(%ebp)
80101dfb:	83 c4 10             	add    $0x10,%esp
80101dfe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101e01:	01 5d dc             	add    %ebx,-0x24(%ebp)
80101e04:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80101e07:	77 97                	ja     80101da0 <writei+0x60>
  }

  if(n > 0 && off > ip->size){
80101e09:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101e0c:	3b 70 58             	cmp    0x58(%eax),%esi
80101e0f:	77 37                	ja     80101e48 <writei+0x108>
    ip->size = off;
    iupdate(ip);
  }
  return n;
80101e11:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80101e14:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101e17:	5b                   	pop    %ebx
80101e18:	5e                   	pop    %esi
80101e19:	5f                   	pop    %edi
80101e1a:	5d                   	pop    %ebp
80101e1b:	c3                   	ret    
80101e1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101e20:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101e24:	66 83 f8 09          	cmp    $0x9,%ax
80101e28:	77 32                	ja     80101e5c <writei+0x11c>
80101e2a:	8b 04 c5 64 19 11 80 	mov    -0x7feee69c(,%eax,8),%eax
80101e31:	85 c0                	test   %eax,%eax
80101e33:	74 27                	je     80101e5c <writei+0x11c>
    return devsw[ip->major].write(ip, src, n);
80101e35:	89 7d 10             	mov    %edi,0x10(%ebp)
}
80101e38:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101e3b:	5b                   	pop    %ebx
80101e3c:	5e                   	pop    %esi
80101e3d:	5f                   	pop    %edi
80101e3e:	5d                   	pop    %ebp
    return devsw[ip->major].write(ip, src, n);
80101e3f:	ff e0                	jmp    *%eax
80101e41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    ip->size = off;
80101e48:	8b 45 d8             	mov    -0x28(%ebp),%eax
    iupdate(ip);
80101e4b:	83 ec 0c             	sub    $0xc,%esp
    ip->size = off;
80101e4e:	89 70 58             	mov    %esi,0x58(%eax)
    iupdate(ip);
80101e51:	50                   	push   %eax
80101e52:	e8 29 fa ff ff       	call   80101880 <iupdate>
80101e57:	83 c4 10             	add    $0x10,%esp
80101e5a:	eb b5                	jmp    80101e11 <writei+0xd1>
      return -1;
80101e5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e61:	eb b1                	jmp    80101e14 <writei+0xd4>
80101e63:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101e6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101e70 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101e70:	f3 0f 1e fb          	endbr32 
80101e74:	55                   	push   %ebp
80101e75:	89 e5                	mov    %esp,%ebp
80101e77:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101e7a:	6a 0e                	push   $0xe
80101e7c:	ff 75 0c             	pushl  0xc(%ebp)
80101e7f:	ff 75 08             	pushl  0x8(%ebp)
80101e82:	e8 a9 2a 00 00       	call   80104930 <strncmp>
}
80101e87:	c9                   	leave  
80101e88:	c3                   	ret    
80101e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101e90 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101e90:	f3 0f 1e fb          	endbr32 
80101e94:	55                   	push   %ebp
80101e95:	89 e5                	mov    %esp,%ebp
80101e97:	57                   	push   %edi
80101e98:	56                   	push   %esi
80101e99:	53                   	push   %ebx
80101e9a:	83 ec 1c             	sub    $0x1c,%esp
80101e9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80101ea0:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101ea5:	0f 85 89 00 00 00    	jne    80101f34 <dirlookup+0xa4>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101eab:	8b 53 58             	mov    0x58(%ebx),%edx
80101eae:	31 ff                	xor    %edi,%edi
80101eb0:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101eb3:	85 d2                	test   %edx,%edx
80101eb5:	74 42                	je     80101ef9 <dirlookup+0x69>
80101eb7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101ebe:	66 90                	xchg   %ax,%ax
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101ec0:	6a 10                	push   $0x10
80101ec2:	57                   	push   %edi
80101ec3:	56                   	push   %esi
80101ec4:	53                   	push   %ebx
80101ec5:	e8 76 fd ff ff       	call   80101c40 <readi>
80101eca:	83 c4 10             	add    $0x10,%esp
80101ecd:	83 f8 10             	cmp    $0x10,%eax
80101ed0:	75 55                	jne    80101f27 <dirlookup+0x97>
      panic("dirlookup read");
    if(de.inum == 0)
80101ed2:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101ed7:	74 18                	je     80101ef1 <dirlookup+0x61>
  return strncmp(s, t, DIRSIZ);
80101ed9:	83 ec 04             	sub    $0x4,%esp
80101edc:	8d 45 da             	lea    -0x26(%ebp),%eax
80101edf:	6a 0e                	push   $0xe
80101ee1:	50                   	push   %eax
80101ee2:	ff 75 0c             	pushl  0xc(%ebp)
80101ee5:	e8 46 2a 00 00       	call   80104930 <strncmp>
      continue;
    if(namecmp(name, de.name) == 0){
80101eea:	83 c4 10             	add    $0x10,%esp
80101eed:	85 c0                	test   %eax,%eax
80101eef:	74 17                	je     80101f08 <dirlookup+0x78>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101ef1:	83 c7 10             	add    $0x10,%edi
80101ef4:	3b 7b 58             	cmp    0x58(%ebx),%edi
80101ef7:	72 c7                	jb     80101ec0 <dirlookup+0x30>
      return iget(dp->dev, inum);
    }
  }

  return 0;
}
80101ef9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80101efc:	31 c0                	xor    %eax,%eax
}
80101efe:	5b                   	pop    %ebx
80101eff:	5e                   	pop    %esi
80101f00:	5f                   	pop    %edi
80101f01:	5d                   	pop    %ebp
80101f02:	c3                   	ret    
80101f03:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101f07:	90                   	nop
      if(poff)
80101f08:	8b 45 10             	mov    0x10(%ebp),%eax
80101f0b:	85 c0                	test   %eax,%eax
80101f0d:	74 05                	je     80101f14 <dirlookup+0x84>
        *poff = off;
80101f0f:	8b 45 10             	mov    0x10(%ebp),%eax
80101f12:	89 38                	mov    %edi,(%eax)
      inum = de.inum;
80101f14:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101f18:	8b 03                	mov    (%ebx),%eax
80101f1a:	e8 a1 f4 ff ff       	call   801013c0 <iget>
}
80101f1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f22:	5b                   	pop    %ebx
80101f23:	5e                   	pop    %esi
80101f24:	5f                   	pop    %edi
80101f25:	5d                   	pop    %ebp
80101f26:	c3                   	ret    
      panic("dirlookup read");
80101f27:	83 ec 0c             	sub    $0xc,%esp
80101f2a:	68 99 7b 10 80       	push   $0x80107b99
80101f2f:	e8 4c e5 ff ff       	call   80100480 <panic>
    panic("dirlookup not DIR");
80101f34:	83 ec 0c             	sub    $0xc,%esp
80101f37:	68 87 7b 10 80       	push   $0x80107b87
80101f3c:	e8 3f e5 ff ff       	call   80100480 <panic>
80101f41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101f48:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101f4f:	90                   	nop

80101f50 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101f50:	55                   	push   %ebp
80101f51:	89 e5                	mov    %esp,%ebp
80101f53:	57                   	push   %edi
80101f54:	56                   	push   %esi
80101f55:	53                   	push   %ebx
80101f56:	89 c3                	mov    %eax,%ebx
80101f58:	83 ec 1c             	sub    $0x1c,%esp
  struct inode *ip, *next;

  if(*path == '/')
80101f5b:	80 38 2f             	cmpb   $0x2f,(%eax)
{
80101f5e:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101f61:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  if(*path == '/')
80101f64:	0f 84 86 01 00 00    	je     801020f0 <namex+0x1a0>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101f6a:	e8 d1 1b 00 00       	call   80103b40 <myproc>
  acquire(&icache.lock);
80101f6f:	83 ec 0c             	sub    $0xc,%esp
80101f72:	89 df                	mov    %ebx,%edi
    ip = idup(myproc()->cwd);
80101f74:	8b 70 68             	mov    0x68(%eax),%esi
  acquire(&icache.lock);
80101f77:	68 e0 19 11 80       	push   $0x801119e0
80101f7c:	e8 1f 27 00 00       	call   801046a0 <acquire>
  ip->ref++;
80101f81:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80101f85:	c7 04 24 e0 19 11 80 	movl   $0x801119e0,(%esp)
80101f8c:	e8 3f 28 00 00       	call   801047d0 <release>
80101f91:	83 c4 10             	add    $0x10,%esp
80101f94:	eb 0d                	jmp    80101fa3 <namex+0x53>
80101f96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101f9d:	8d 76 00             	lea    0x0(%esi),%esi
    path++;
80101fa0:	83 c7 01             	add    $0x1,%edi
  while(*path == '/')
80101fa3:	0f b6 07             	movzbl (%edi),%eax
80101fa6:	3c 2f                	cmp    $0x2f,%al
80101fa8:	74 f6                	je     80101fa0 <namex+0x50>
  if(*path == 0)
80101faa:	84 c0                	test   %al,%al
80101fac:	0f 84 ee 00 00 00    	je     801020a0 <namex+0x150>
  while(*path != '/' && *path != 0)
80101fb2:	0f b6 07             	movzbl (%edi),%eax
80101fb5:	84 c0                	test   %al,%al
80101fb7:	0f 84 fb 00 00 00    	je     801020b8 <namex+0x168>
80101fbd:	89 fb                	mov    %edi,%ebx
80101fbf:	3c 2f                	cmp    $0x2f,%al
80101fc1:	0f 84 f1 00 00 00    	je     801020b8 <namex+0x168>
80101fc7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101fce:	66 90                	xchg   %ax,%ax
80101fd0:	0f b6 43 01          	movzbl 0x1(%ebx),%eax
    path++;
80101fd4:	83 c3 01             	add    $0x1,%ebx
  while(*path != '/' && *path != 0)
80101fd7:	3c 2f                	cmp    $0x2f,%al
80101fd9:	74 04                	je     80101fdf <namex+0x8f>
80101fdb:	84 c0                	test   %al,%al
80101fdd:	75 f1                	jne    80101fd0 <namex+0x80>
  len = path - s;
80101fdf:	89 d8                	mov    %ebx,%eax
80101fe1:	29 f8                	sub    %edi,%eax
  if(len >= DIRSIZ)
80101fe3:	83 f8 0d             	cmp    $0xd,%eax
80101fe6:	0f 8e 84 00 00 00    	jle    80102070 <namex+0x120>
    memmove(name, s, DIRSIZ);
80101fec:	83 ec 04             	sub    $0x4,%esp
80101fef:	6a 0e                	push   $0xe
80101ff1:	57                   	push   %edi
    path++;
80101ff2:	89 df                	mov    %ebx,%edi
    memmove(name, s, DIRSIZ);
80101ff4:	ff 75 e4             	pushl  -0x1c(%ebp)
80101ff7:	e8 c4 28 00 00       	call   801048c0 <memmove>
80101ffc:	83 c4 10             	add    $0x10,%esp
  while(*path == '/')
80101fff:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80102002:	75 0c                	jne    80102010 <namex+0xc0>
80102004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80102008:	83 c7 01             	add    $0x1,%edi
  while(*path == '/')
8010200b:	80 3f 2f             	cmpb   $0x2f,(%edi)
8010200e:	74 f8                	je     80102008 <namex+0xb8>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80102010:	83 ec 0c             	sub    $0xc,%esp
80102013:	56                   	push   %esi
80102014:	e8 27 f9 ff ff       	call   80101940 <ilock>
    if(ip->type != T_DIR){
80102019:	83 c4 10             	add    $0x10,%esp
8010201c:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80102021:	0f 85 a1 00 00 00    	jne    801020c8 <namex+0x178>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
80102027:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010202a:	85 d2                	test   %edx,%edx
8010202c:	74 09                	je     80102037 <namex+0xe7>
8010202e:	80 3f 00             	cmpb   $0x0,(%edi)
80102031:	0f 84 d9 00 00 00    	je     80102110 <namex+0x1c0>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102037:	83 ec 04             	sub    $0x4,%esp
8010203a:	6a 00                	push   $0x0
8010203c:	ff 75 e4             	pushl  -0x1c(%ebp)
8010203f:	56                   	push   %esi
80102040:	e8 4b fe ff ff       	call   80101e90 <dirlookup>
80102045:	83 c4 10             	add    $0x10,%esp
80102048:	89 c3                	mov    %eax,%ebx
8010204a:	85 c0                	test   %eax,%eax
8010204c:	74 7a                	je     801020c8 <namex+0x178>
  iunlock(ip);
8010204e:	83 ec 0c             	sub    $0xc,%esp
80102051:	56                   	push   %esi
80102052:	e8 c9 f9 ff ff       	call   80101a20 <iunlock>
  iput(ip);
80102057:	89 34 24             	mov    %esi,(%esp)
8010205a:	89 de                	mov    %ebx,%esi
8010205c:	e8 0f fa ff ff       	call   80101a70 <iput>
80102061:	83 c4 10             	add    $0x10,%esp
80102064:	e9 3a ff ff ff       	jmp    80101fa3 <namex+0x53>
80102069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102070:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102073:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80102076:	89 4d dc             	mov    %ecx,-0x24(%ebp)
    memmove(name, s, len);
80102079:	83 ec 04             	sub    $0x4,%esp
8010207c:	50                   	push   %eax
8010207d:	57                   	push   %edi
    name[len] = 0;
8010207e:	89 df                	mov    %ebx,%edi
    memmove(name, s, len);
80102080:	ff 75 e4             	pushl  -0x1c(%ebp)
80102083:	e8 38 28 00 00       	call   801048c0 <memmove>
    name[len] = 0;
80102088:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010208b:	83 c4 10             	add    $0x10,%esp
8010208e:	c6 00 00             	movb   $0x0,(%eax)
80102091:	e9 69 ff ff ff       	jmp    80101fff <namex+0xaf>
80102096:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010209d:	8d 76 00             	lea    0x0(%esi),%esi
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801020a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801020a3:	85 c0                	test   %eax,%eax
801020a5:	0f 85 85 00 00 00    	jne    80102130 <namex+0x1e0>
    iput(ip);
    return 0;
  }
  return ip;
}
801020ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
801020ae:	89 f0                	mov    %esi,%eax
801020b0:	5b                   	pop    %ebx
801020b1:	5e                   	pop    %esi
801020b2:	5f                   	pop    %edi
801020b3:	5d                   	pop    %ebp
801020b4:	c3                   	ret    
801020b5:	8d 76 00             	lea    0x0(%esi),%esi
  while(*path != '/' && *path != 0)
801020b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801020bb:	89 fb                	mov    %edi,%ebx
801020bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
801020c0:	31 c0                	xor    %eax,%eax
801020c2:	eb b5                	jmp    80102079 <namex+0x129>
801020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  iunlock(ip);
801020c8:	83 ec 0c             	sub    $0xc,%esp
801020cb:	56                   	push   %esi
801020cc:	e8 4f f9 ff ff       	call   80101a20 <iunlock>
  iput(ip);
801020d1:	89 34 24             	mov    %esi,(%esp)
      return 0;
801020d4:	31 f6                	xor    %esi,%esi
  iput(ip);
801020d6:	e8 95 f9 ff ff       	call   80101a70 <iput>
      return 0;
801020db:	83 c4 10             	add    $0x10,%esp
}
801020de:	8d 65 f4             	lea    -0xc(%ebp),%esp
801020e1:	89 f0                	mov    %esi,%eax
801020e3:	5b                   	pop    %ebx
801020e4:	5e                   	pop    %esi
801020e5:	5f                   	pop    %edi
801020e6:	5d                   	pop    %ebp
801020e7:	c3                   	ret    
801020e8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801020ef:	90                   	nop
    ip = iget(ROOTDEV, ROOTINO);
801020f0:	ba 01 00 00 00       	mov    $0x1,%edx
801020f5:	b8 01 00 00 00       	mov    $0x1,%eax
801020fa:	89 df                	mov    %ebx,%edi
801020fc:	e8 bf f2 ff ff       	call   801013c0 <iget>
80102101:	89 c6                	mov    %eax,%esi
80102103:	e9 9b fe ff ff       	jmp    80101fa3 <namex+0x53>
80102108:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010210f:	90                   	nop
      iunlock(ip);
80102110:	83 ec 0c             	sub    $0xc,%esp
80102113:	56                   	push   %esi
80102114:	e8 07 f9 ff ff       	call   80101a20 <iunlock>
      return ip;
80102119:	83 c4 10             	add    $0x10,%esp
}
8010211c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010211f:	89 f0                	mov    %esi,%eax
80102121:	5b                   	pop    %ebx
80102122:	5e                   	pop    %esi
80102123:	5f                   	pop    %edi
80102124:	5d                   	pop    %ebp
80102125:	c3                   	ret    
80102126:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010212d:	8d 76 00             	lea    0x0(%esi),%esi
    iput(ip);
80102130:	83 ec 0c             	sub    $0xc,%esp
80102133:	56                   	push   %esi
    return 0;
80102134:	31 f6                	xor    %esi,%esi
    iput(ip);
80102136:	e8 35 f9 ff ff       	call   80101a70 <iput>
    return 0;
8010213b:	83 c4 10             	add    $0x10,%esp
8010213e:	e9 68 ff ff ff       	jmp    801020ab <namex+0x15b>
80102143:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010214a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102150 <dirlink>:
{
80102150:	f3 0f 1e fb          	endbr32 
80102154:	55                   	push   %ebp
80102155:	89 e5                	mov    %esp,%ebp
80102157:	57                   	push   %edi
80102158:	56                   	push   %esi
80102159:	53                   	push   %ebx
8010215a:	83 ec 20             	sub    $0x20,%esp
8010215d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((ip = dirlookup(dp, name, 0)) != 0){
80102160:	6a 00                	push   $0x0
80102162:	ff 75 0c             	pushl  0xc(%ebp)
80102165:	53                   	push   %ebx
80102166:	e8 25 fd ff ff       	call   80101e90 <dirlookup>
8010216b:	83 c4 10             	add    $0x10,%esp
8010216e:	85 c0                	test   %eax,%eax
80102170:	75 6b                	jne    801021dd <dirlink+0x8d>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102172:	8b 7b 58             	mov    0x58(%ebx),%edi
80102175:	8d 75 d8             	lea    -0x28(%ebp),%esi
80102178:	85 ff                	test   %edi,%edi
8010217a:	74 2d                	je     801021a9 <dirlink+0x59>
8010217c:	31 ff                	xor    %edi,%edi
8010217e:	8d 75 d8             	lea    -0x28(%ebp),%esi
80102181:	eb 0d                	jmp    80102190 <dirlink+0x40>
80102183:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102187:	90                   	nop
80102188:	83 c7 10             	add    $0x10,%edi
8010218b:	3b 7b 58             	cmp    0x58(%ebx),%edi
8010218e:	73 19                	jae    801021a9 <dirlink+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102190:	6a 10                	push   $0x10
80102192:	57                   	push   %edi
80102193:	56                   	push   %esi
80102194:	53                   	push   %ebx
80102195:	e8 a6 fa ff ff       	call   80101c40 <readi>
8010219a:	83 c4 10             	add    $0x10,%esp
8010219d:	83 f8 10             	cmp    $0x10,%eax
801021a0:	75 4e                	jne    801021f0 <dirlink+0xa0>
    if(de.inum == 0)
801021a2:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
801021a7:	75 df                	jne    80102188 <dirlink+0x38>
  strncpy(de.name, name, DIRSIZ);
801021a9:	83 ec 04             	sub    $0x4,%esp
801021ac:	8d 45 da             	lea    -0x26(%ebp),%eax
801021af:	6a 0e                	push   $0xe
801021b1:	ff 75 0c             	pushl  0xc(%ebp)
801021b4:	50                   	push   %eax
801021b5:	e8 c6 27 00 00       	call   80104980 <strncpy>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021ba:	6a 10                	push   $0x10
  de.inum = inum;
801021bc:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021bf:	57                   	push   %edi
801021c0:	56                   	push   %esi
801021c1:	53                   	push   %ebx
  de.inum = inum;
801021c2:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021c6:	e8 75 fb ff ff       	call   80101d40 <writei>
801021cb:	83 c4 20             	add    $0x20,%esp
801021ce:	83 f8 10             	cmp    $0x10,%eax
801021d1:	75 2a                	jne    801021fd <dirlink+0xad>
  return 0;
801021d3:	31 c0                	xor    %eax,%eax
}
801021d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801021d8:	5b                   	pop    %ebx
801021d9:	5e                   	pop    %esi
801021da:	5f                   	pop    %edi
801021db:	5d                   	pop    %ebp
801021dc:	c3                   	ret    
    iput(ip);
801021dd:	83 ec 0c             	sub    $0xc,%esp
801021e0:	50                   	push   %eax
801021e1:	e8 8a f8 ff ff       	call   80101a70 <iput>
    return -1;
801021e6:	83 c4 10             	add    $0x10,%esp
801021e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021ee:	eb e5                	jmp    801021d5 <dirlink+0x85>
      panic("dirlink read");
801021f0:	83 ec 0c             	sub    $0xc,%esp
801021f3:	68 a8 7b 10 80       	push   $0x80107ba8
801021f8:	e8 83 e2 ff ff       	call   80100480 <panic>
    panic("dirlink");
801021fd:	83 ec 0c             	sub    $0xc,%esp
80102200:	68 86 81 10 80       	push   $0x80108186
80102205:	e8 76 e2 ff ff       	call   80100480 <panic>
8010220a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102210 <namei>:

struct inode*
namei(char *path)
{
80102210:	f3 0f 1e fb          	endbr32 
80102214:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102215:	31 d2                	xor    %edx,%edx
{
80102217:	89 e5                	mov    %esp,%ebp
80102219:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 0, name);
8010221c:	8b 45 08             	mov    0x8(%ebp),%eax
8010221f:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80102222:	e8 29 fd ff ff       	call   80101f50 <namex>
}
80102227:	c9                   	leave  
80102228:	c3                   	ret    
80102229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102230 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102230:	f3 0f 1e fb          	endbr32 
80102234:	55                   	push   %ebp
  return namex(path, 1, name);
80102235:	ba 01 00 00 00       	mov    $0x1,%edx
{
8010223a:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
8010223c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010223f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102242:	5d                   	pop    %ebp
  return namex(path, 1, name);
80102243:	e9 08 fd ff ff       	jmp    80101f50 <namex>
80102248:	66 90                	xchg   %ax,%ax
8010224a:	66 90                	xchg   %ax,%ax
8010224c:	66 90                	xchg   %ax,%ax
8010224e:	66 90                	xchg   %ax,%ax

80102250 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102250:	55                   	push   %ebp
80102251:	89 e5                	mov    %esp,%ebp
80102253:	56                   	push   %esi
80102254:	53                   	push   %ebx
  if(b == 0)
80102255:	85 c0                	test   %eax,%eax
80102257:	0f 84 af 00 00 00    	je     8010230c <idestart+0xbc>
    panic("idestart");
  if(b->blockno >= FSSIZE)
8010225d:	8b 70 08             	mov    0x8(%eax),%esi
80102260:	89 c3                	mov    %eax,%ebx
80102262:	81 fe ff f3 01 00    	cmp    $0x1f3ff,%esi
80102268:	0f 87 91 00 00 00    	ja     801022ff <idestart+0xaf>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010226e:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
80102273:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102277:	90                   	nop
80102278:	89 ca                	mov    %ecx,%edx
8010227a:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
8010227b:	83 e0 c0             	and    $0xffffffc0,%eax
8010227e:	3c 40                	cmp    $0x40,%al
80102280:	75 f6                	jne    80102278 <idestart+0x28>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102282:	31 c0                	xor    %eax,%eax
80102284:	ba f6 03 00 00       	mov    $0x3f6,%edx
80102289:	ee                   	out    %al,(%dx)
8010228a:	b8 01 00 00 00       	mov    $0x1,%eax
8010228f:	ba f2 01 00 00       	mov    $0x1f2,%edx
80102294:	ee                   	out    %al,(%dx)
80102295:	ba f3 01 00 00       	mov    $0x1f3,%edx
8010229a:	89 f0                	mov    %esi,%eax
8010229c:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
8010229d:	89 f0                	mov    %esi,%eax
8010229f:	ba f4 01 00 00       	mov    $0x1f4,%edx
801022a4:	c1 f8 08             	sar    $0x8,%eax
801022a7:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
801022a8:	89 f0                	mov    %esi,%eax
801022aa:	ba f5 01 00 00       	mov    $0x1f5,%edx
801022af:	c1 f8 10             	sar    $0x10,%eax
801022b2:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801022b3:	0f b6 43 04          	movzbl 0x4(%ebx),%eax
801022b7:	ba f6 01 00 00       	mov    $0x1f6,%edx
801022bc:	c1 e0 04             	shl    $0x4,%eax
801022bf:	83 e0 10             	and    $0x10,%eax
801022c2:	83 c8 e0             	or     $0xffffffe0,%eax
801022c5:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
801022c6:	f6 03 04             	testb  $0x4,(%ebx)
801022c9:	75 15                	jne    801022e0 <idestart+0x90>
801022cb:	b8 20 00 00 00       	mov    $0x20,%eax
801022d0:	89 ca                	mov    %ecx,%edx
801022d2:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
801022d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
801022d6:	5b                   	pop    %ebx
801022d7:	5e                   	pop    %esi
801022d8:	5d                   	pop    %ebp
801022d9:	c3                   	ret    
801022da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801022e0:	b8 30 00 00 00       	mov    $0x30,%eax
801022e5:	89 ca                	mov    %ecx,%edx
801022e7:	ee                   	out    %al,(%dx)
  asm volatile("cld; rep outsl" :
801022e8:	b9 80 00 00 00       	mov    $0x80,%ecx
    outsl(0x1f0, b->data, BSIZE/4);
801022ed:	8d 73 5c             	lea    0x5c(%ebx),%esi
801022f0:	ba f0 01 00 00       	mov    $0x1f0,%edx
801022f5:	fc                   	cld    
801022f6:	f3 6f                	rep outsl %ds:(%esi),(%dx)
}
801022f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801022fb:	5b                   	pop    %ebx
801022fc:	5e                   	pop    %esi
801022fd:	5d                   	pop    %ebp
801022fe:	c3                   	ret    
    panic("incorrect blockno");
801022ff:	83 ec 0c             	sub    $0xc,%esp
80102302:	68 14 7c 10 80       	push   $0x80107c14
80102307:	e8 74 e1 ff ff       	call   80100480 <panic>
    panic("idestart");
8010230c:	83 ec 0c             	sub    $0xc,%esp
8010230f:	68 0b 7c 10 80       	push   $0x80107c0b
80102314:	e8 67 e1 ff ff       	call   80100480 <panic>
80102319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102320 <ideinit>:
{
80102320:	f3 0f 1e fb          	endbr32 
80102324:	55                   	push   %ebp
80102325:	89 e5                	mov    %esp,%ebp
80102327:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
8010232a:	68 26 7c 10 80       	push   $0x80107c26
8010232f:	68 80 b5 10 80       	push   $0x8010b580
80102334:	e8 57 22 00 00       	call   80104590 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102339:	58                   	pop    %eax
8010233a:	a1 60 3d 11 80       	mov    0x80113d60,%eax
8010233f:	5a                   	pop    %edx
80102340:	83 e8 01             	sub    $0x1,%eax
80102343:	50                   	push   %eax
80102344:	6a 0e                	push   $0xe
80102346:	e8 b5 02 00 00       	call   80102600 <ioapicenable>
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
8010234b:	83 c4 10             	add    $0x10,%esp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010234e:	ba f7 01 00 00       	mov    $0x1f7,%edx
80102353:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102357:	90                   	nop
80102358:	ec                   	in     (%dx),%al
80102359:	83 e0 c0             	and    $0xffffffc0,%eax
8010235c:	3c 40                	cmp    $0x40,%al
8010235e:	75 f8                	jne    80102358 <ideinit+0x38>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102360:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80102365:	ba f6 01 00 00       	mov    $0x1f6,%edx
8010236a:	ee                   	out    %al,(%dx)
8010236b:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102370:	ba f7 01 00 00       	mov    $0x1f7,%edx
80102375:	eb 0e                	jmp    80102385 <ideinit+0x65>
80102377:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010237e:	66 90                	xchg   %ax,%ax
  for(i=0; i<1000; i++){
80102380:	83 e9 01             	sub    $0x1,%ecx
80102383:	74 0f                	je     80102394 <ideinit+0x74>
80102385:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80102386:	84 c0                	test   %al,%al
80102388:	74 f6                	je     80102380 <ideinit+0x60>
      havedisk1 = 1;
8010238a:	c7 05 60 b5 10 80 01 	movl   $0x1,0x8010b560
80102391:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102394:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80102399:	ba f6 01 00 00       	mov    $0x1f6,%edx
8010239e:	ee                   	out    %al,(%dx)
}
8010239f:	c9                   	leave  
801023a0:	c3                   	ret    
801023a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801023a8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801023af:	90                   	nop

801023b0 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801023b0:	f3 0f 1e fb          	endbr32 
801023b4:	55                   	push   %ebp
801023b5:	89 e5                	mov    %esp,%ebp
801023b7:	57                   	push   %edi
801023b8:	56                   	push   %esi
801023b9:	53                   	push   %ebx
801023ba:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801023bd:	68 80 b5 10 80       	push   $0x8010b580
801023c2:	e8 d9 22 00 00       	call   801046a0 <acquire>

  if((b = idequeue) == 0){
801023c7:	8b 1d 64 b5 10 80    	mov    0x8010b564,%ebx
801023cd:	83 c4 10             	add    $0x10,%esp
801023d0:	85 db                	test   %ebx,%ebx
801023d2:	74 5f                	je     80102433 <ideintr+0x83>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
801023d4:	8b 43 58             	mov    0x58(%ebx),%eax
801023d7:	a3 64 b5 10 80       	mov    %eax,0x8010b564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801023dc:	8b 33                	mov    (%ebx),%esi
801023de:	f7 c6 04 00 00 00    	test   $0x4,%esi
801023e4:	75 2b                	jne    80102411 <ideintr+0x61>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801023e6:	ba f7 01 00 00       	mov    $0x1f7,%edx
801023eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801023ef:	90                   	nop
801023f0:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801023f1:	89 c1                	mov    %eax,%ecx
801023f3:	83 e1 c0             	and    $0xffffffc0,%ecx
801023f6:	80 f9 40             	cmp    $0x40,%cl
801023f9:	75 f5                	jne    801023f0 <ideintr+0x40>
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801023fb:	a8 21                	test   $0x21,%al
801023fd:	75 12                	jne    80102411 <ideintr+0x61>
    insl(0x1f0, b->data, BSIZE/4);
801023ff:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80102402:	b9 80 00 00 00       	mov    $0x80,%ecx
80102407:	ba f0 01 00 00       	mov    $0x1f0,%edx
8010240c:	fc                   	cld    
8010240d:	f3 6d                	rep insl (%dx),%es:(%edi)
8010240f:	8b 33                	mov    (%ebx),%esi

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
  b->flags &= ~B_DIRTY;
80102411:	83 e6 fb             	and    $0xfffffffb,%esi
  wakeup(b);
80102414:	83 ec 0c             	sub    $0xc,%esp
  b->flags &= ~B_DIRTY;
80102417:	83 ce 02             	or     $0x2,%esi
8010241a:	89 33                	mov    %esi,(%ebx)
  wakeup(b);
8010241c:	53                   	push   %ebx
8010241d:	e8 7e 1e 00 00       	call   801042a0 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102422:	a1 64 b5 10 80       	mov    0x8010b564,%eax
80102427:	83 c4 10             	add    $0x10,%esp
8010242a:	85 c0                	test   %eax,%eax
8010242c:	74 05                	je     80102433 <ideintr+0x83>
    idestart(idequeue);
8010242e:	e8 1d fe ff ff       	call   80102250 <idestart>
    release(&idelock);
80102433:	83 ec 0c             	sub    $0xc,%esp
80102436:	68 80 b5 10 80       	push   $0x8010b580
8010243b:	e8 90 23 00 00       	call   801047d0 <release>

  release(&idelock);
}
80102440:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102443:	5b                   	pop    %ebx
80102444:	5e                   	pop    %esi
80102445:	5f                   	pop    %edi
80102446:	5d                   	pop    %ebp
80102447:	c3                   	ret    
80102448:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010244f:	90                   	nop

80102450 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102450:	f3 0f 1e fb          	endbr32 
80102454:	55                   	push   %ebp
80102455:	89 e5                	mov    %esp,%ebp
80102457:	53                   	push   %ebx
80102458:	83 ec 10             	sub    $0x10,%esp
8010245b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
8010245e:	8d 43 0c             	lea    0xc(%ebx),%eax
80102461:	50                   	push   %eax
80102462:	e8 f9 20 00 00       	call   80104560 <holdingsleep>
80102467:	83 c4 10             	add    $0x10,%esp
8010246a:	85 c0                	test   %eax,%eax
8010246c:	0f 84 cf 00 00 00    	je     80102541 <iderw+0xf1>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102472:	8b 03                	mov    (%ebx),%eax
80102474:	83 e0 06             	and    $0x6,%eax
80102477:	83 f8 02             	cmp    $0x2,%eax
8010247a:	0f 84 b4 00 00 00    	je     80102534 <iderw+0xe4>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80102480:	8b 53 04             	mov    0x4(%ebx),%edx
80102483:	85 d2                	test   %edx,%edx
80102485:	74 0d                	je     80102494 <iderw+0x44>
80102487:	a1 60 b5 10 80       	mov    0x8010b560,%eax
8010248c:	85 c0                	test   %eax,%eax
8010248e:	0f 84 93 00 00 00    	je     80102527 <iderw+0xd7>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80102494:	83 ec 0c             	sub    $0xc,%esp
80102497:	68 80 b5 10 80       	push   $0x8010b580
8010249c:	e8 ff 21 00 00       	call   801046a0 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801024a1:	a1 64 b5 10 80       	mov    0x8010b564,%eax
  b->qnext = 0;
801024a6:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801024ad:	83 c4 10             	add    $0x10,%esp
801024b0:	85 c0                	test   %eax,%eax
801024b2:	74 6c                	je     80102520 <iderw+0xd0>
801024b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801024b8:	89 c2                	mov    %eax,%edx
801024ba:	8b 40 58             	mov    0x58(%eax),%eax
801024bd:	85 c0                	test   %eax,%eax
801024bf:	75 f7                	jne    801024b8 <iderw+0x68>
801024c1:	83 c2 58             	add    $0x58,%edx
    ;
  *pp = b;
801024c4:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
801024c6:	39 1d 64 b5 10 80    	cmp    %ebx,0x8010b564
801024cc:	74 42                	je     80102510 <iderw+0xc0>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801024ce:	8b 03                	mov    (%ebx),%eax
801024d0:	83 e0 06             	and    $0x6,%eax
801024d3:	83 f8 02             	cmp    $0x2,%eax
801024d6:	74 23                	je     801024fb <iderw+0xab>
801024d8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801024df:	90                   	nop
    sleep(b, &idelock);
801024e0:	83 ec 08             	sub    $0x8,%esp
801024e3:	68 80 b5 10 80       	push   $0x8010b580
801024e8:	53                   	push   %ebx
801024e9:	e8 e2 1b 00 00       	call   801040d0 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801024ee:	8b 03                	mov    (%ebx),%eax
801024f0:	83 c4 10             	add    $0x10,%esp
801024f3:	83 e0 06             	and    $0x6,%eax
801024f6:	83 f8 02             	cmp    $0x2,%eax
801024f9:	75 e5                	jne    801024e0 <iderw+0x90>
  }


  release(&idelock);
801024fb:	c7 45 08 80 b5 10 80 	movl   $0x8010b580,0x8(%ebp)
}
80102502:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102505:	c9                   	leave  
  release(&idelock);
80102506:	e9 c5 22 00 00       	jmp    801047d0 <release>
8010250b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010250f:	90                   	nop
    idestart(b);
80102510:	89 d8                	mov    %ebx,%eax
80102512:	e8 39 fd ff ff       	call   80102250 <idestart>
80102517:	eb b5                	jmp    801024ce <iderw+0x7e>
80102519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102520:	ba 64 b5 10 80       	mov    $0x8010b564,%edx
80102525:	eb 9d                	jmp    801024c4 <iderw+0x74>
    panic("iderw: ide disk 1 not present");
80102527:	83 ec 0c             	sub    $0xc,%esp
8010252a:	68 55 7c 10 80       	push   $0x80107c55
8010252f:	e8 4c df ff ff       	call   80100480 <panic>
    panic("iderw: nothing to do");
80102534:	83 ec 0c             	sub    $0xc,%esp
80102537:	68 40 7c 10 80       	push   $0x80107c40
8010253c:	e8 3f df ff ff       	call   80100480 <panic>
    panic("iderw: buf not locked");
80102541:	83 ec 0c             	sub    $0xc,%esp
80102544:	68 2a 7c 10 80       	push   $0x80107c2a
80102549:	e8 32 df ff ff       	call   80100480 <panic>
8010254e:	66 90                	xchg   %ax,%ax

80102550 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
80102550:	f3 0f 1e fb          	endbr32 
80102554:	55                   	push   %ebp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102555:	c7 05 34 36 11 80 00 	movl   $0xfec00000,0x80113634
8010255c:	00 c0 fe 
{
8010255f:	89 e5                	mov    %esp,%ebp
80102561:	56                   	push   %esi
80102562:	53                   	push   %ebx
  ioapic->reg = reg;
80102563:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
8010256a:	00 00 00 
  return ioapic->data;
8010256d:	8b 15 34 36 11 80    	mov    0x80113634,%edx
80102573:	8b 72 10             	mov    0x10(%edx),%esi
  ioapic->reg = reg;
80102576:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
  return ioapic->data;
8010257c:	8b 0d 34 36 11 80    	mov    0x80113634,%ecx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
80102582:	0f b6 15 60 37 11 80 	movzbl 0x80113760,%edx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102589:	c1 ee 10             	shr    $0x10,%esi
8010258c:	89 f0                	mov    %esi,%eax
8010258e:	0f b6 f0             	movzbl %al,%esi
  return ioapic->data;
80102591:	8b 41 10             	mov    0x10(%ecx),%eax
  id = ioapicread(REG_ID) >> 24;
80102594:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80102597:	39 c2                	cmp    %eax,%edx
80102599:	74 16                	je     801025b1 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010259b:	83 ec 0c             	sub    $0xc,%esp
8010259e:	68 74 7c 10 80       	push   $0x80107c74
801025a3:	e8 f8 e1 ff ff       	call   801007a0 <cprintf>
801025a8:	8b 0d 34 36 11 80    	mov    0x80113634,%ecx
801025ae:	83 c4 10             	add    $0x10,%esp
801025b1:	83 c6 21             	add    $0x21,%esi
{
801025b4:	ba 10 00 00 00       	mov    $0x10,%edx
801025b9:	b8 20 00 00 00       	mov    $0x20,%eax
801025be:	66 90                	xchg   %ax,%ax
  ioapic->reg = reg;
801025c0:	89 11                	mov    %edx,(%ecx)

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025c2:	89 c3                	mov    %eax,%ebx
  ioapic->data = data;
801025c4:	8b 0d 34 36 11 80    	mov    0x80113634,%ecx
801025ca:	83 c0 01             	add    $0x1,%eax
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025cd:	81 cb 00 00 01 00    	or     $0x10000,%ebx
  ioapic->data = data;
801025d3:	89 59 10             	mov    %ebx,0x10(%ecx)
  ioapic->reg = reg;
801025d6:	8d 5a 01             	lea    0x1(%edx),%ebx
801025d9:	83 c2 02             	add    $0x2,%edx
801025dc:	89 19                	mov    %ebx,(%ecx)
  ioapic->data = data;
801025de:	8b 0d 34 36 11 80    	mov    0x80113634,%ecx
801025e4:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  for(i = 0; i <= maxintr; i++){
801025eb:	39 f0                	cmp    %esi,%eax
801025ed:	75 d1                	jne    801025c0 <ioapicinit+0x70>
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801025ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
801025f2:	5b                   	pop    %ebx
801025f3:	5e                   	pop    %esi
801025f4:	5d                   	pop    %ebp
801025f5:	c3                   	ret    
801025f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801025fd:	8d 76 00             	lea    0x0(%esi),%esi

80102600 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102600:	f3 0f 1e fb          	endbr32 
80102604:	55                   	push   %ebp
  ioapic->reg = reg;
80102605:	8b 0d 34 36 11 80    	mov    0x80113634,%ecx
{
8010260b:	89 e5                	mov    %esp,%ebp
8010260d:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102610:	8d 50 20             	lea    0x20(%eax),%edx
80102613:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
  ioapic->reg = reg;
80102617:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80102619:	8b 0d 34 36 11 80    	mov    0x80113634,%ecx
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010261f:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
80102622:	89 51 10             	mov    %edx,0x10(%ecx)
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102625:	8b 55 0c             	mov    0xc(%ebp),%edx
  ioapic->reg = reg;
80102628:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
8010262a:	a1 34 36 11 80       	mov    0x80113634,%eax
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010262f:	c1 e2 18             	shl    $0x18,%edx
  ioapic->data = data;
80102632:	89 50 10             	mov    %edx,0x10(%eax)
}
80102635:	5d                   	pop    %ebp
80102636:	c3                   	ret    
80102637:	66 90                	xchg   %ax,%ax
80102639:	66 90                	xchg   %ax,%ax
8010263b:	66 90                	xchg   %ax,%ax
8010263d:	66 90                	xchg   %ax,%ax
8010263f:	90                   	nop

80102640 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102640:	f3 0f 1e fb          	endbr32 
80102644:	55                   	push   %ebp
80102645:	89 e5                	mov    %esp,%ebp
80102647:	53                   	push   %ebx
80102648:	83 ec 04             	sub    $0x4,%esp
8010264b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  
  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010264e:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80102654:	75 7a                	jne    801026d0 <kfree+0x90>
80102656:	81 fb 08 86 11 80    	cmp    $0x80118608,%ebx
8010265c:	72 72                	jb     801026d0 <kfree+0x90>
8010265e:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80102664:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
80102669:	77 65                	ja     801026d0 <kfree+0x90>
    panic("kfree in kalloc.c");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010266b:	83 ec 04             	sub    $0x4,%esp
8010266e:	68 00 10 00 00       	push   $0x1000
80102673:	6a 01                	push   $0x1
80102675:	53                   	push   %ebx
80102676:	e8 a5 21 00 00       	call   80104820 <memset>

  if(kmem.use_lock)
8010267b:	8b 15 74 36 11 80    	mov    0x80113674,%edx
80102681:	83 c4 10             	add    $0x10,%esp
80102684:	85 d2                	test   %edx,%edx
80102686:	75 20                	jne    801026a8 <kfree+0x68>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80102688:	a1 78 36 11 80       	mov    0x80113678,%eax
8010268d:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
  if(kmem.use_lock)
8010268f:	a1 74 36 11 80       	mov    0x80113674,%eax
  kmem.freelist = r;
80102694:	89 1d 78 36 11 80    	mov    %ebx,0x80113678
  if(kmem.use_lock)
8010269a:	85 c0                	test   %eax,%eax
8010269c:	75 22                	jne    801026c0 <kfree+0x80>
    release(&kmem.lock);
}
8010269e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801026a1:	c9                   	leave  
801026a2:	c3                   	ret    
801026a3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801026a7:	90                   	nop
    acquire(&kmem.lock);
801026a8:	83 ec 0c             	sub    $0xc,%esp
801026ab:	68 40 36 11 80       	push   $0x80113640
801026b0:	e8 eb 1f 00 00       	call   801046a0 <acquire>
801026b5:	83 c4 10             	add    $0x10,%esp
801026b8:	eb ce                	jmp    80102688 <kfree+0x48>
801026ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    release(&kmem.lock);
801026c0:	c7 45 08 40 36 11 80 	movl   $0x80113640,0x8(%ebp)
}
801026c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801026ca:	c9                   	leave  
    release(&kmem.lock);
801026cb:	e9 00 21 00 00       	jmp    801047d0 <release>
    panic("kfree in kalloc.c");
801026d0:	83 ec 0c             	sub    $0xc,%esp
801026d3:	68 a6 7c 10 80       	push   $0x80107ca6
801026d8:	e8 a3 dd ff ff       	call   80100480 <panic>
801026dd:	8d 76 00             	lea    0x0(%esi),%esi

801026e0 <freerange>:
{
801026e0:	f3 0f 1e fb          	endbr32 
801026e4:	55                   	push   %ebp
801026e5:	89 e5                	mov    %esp,%ebp
801026e7:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
801026e8:	8b 45 08             	mov    0x8(%ebp),%eax
{
801026eb:	8b 75 0c             	mov    0xc(%ebp),%esi
801026ee:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
801026ef:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801026f5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026fb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80102701:	39 de                	cmp    %ebx,%esi
80102703:	72 1f                	jb     80102724 <freerange+0x44>
80102705:	8d 76 00             	lea    0x0(%esi),%esi
    kfree(p);
80102708:	83 ec 0c             	sub    $0xc,%esp
8010270b:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102711:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
80102717:	50                   	push   %eax
80102718:	e8 23 ff ff ff       	call   80102640 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010271d:	83 c4 10             	add    $0x10,%esp
80102720:	39 f3                	cmp    %esi,%ebx
80102722:	76 e4                	jbe    80102708 <freerange+0x28>
}
80102724:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102727:	5b                   	pop    %ebx
80102728:	5e                   	pop    %esi
80102729:	5d                   	pop    %ebp
8010272a:	c3                   	ret    
8010272b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010272f:	90                   	nop

80102730 <kinit1>:
{
80102730:	f3 0f 1e fb          	endbr32 
80102734:	55                   	push   %ebp
80102735:	89 e5                	mov    %esp,%ebp
80102737:	56                   	push   %esi
80102738:	53                   	push   %ebx
80102739:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
8010273c:	83 ec 08             	sub    $0x8,%esp
8010273f:	68 b8 7c 10 80       	push   $0x80107cb8
80102744:	68 40 36 11 80       	push   $0x80113640
80102749:	e8 42 1e 00 00       	call   80104590 <initlock>
  p = (char*)PGROUNDUP((uint)vstart);
8010274e:	8b 45 08             	mov    0x8(%ebp),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102751:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102754:	c7 05 74 36 11 80 00 	movl   $0x0,0x80113674
8010275b:	00 00 00 
  p = (char*)PGROUNDUP((uint)vstart);
8010275e:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102764:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010276a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80102770:	39 de                	cmp    %ebx,%esi
80102772:	72 20                	jb     80102794 <kinit1+0x64>
80102774:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
80102778:	83 ec 0c             	sub    $0xc,%esp
8010277b:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102781:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
80102787:	50                   	push   %eax
80102788:	e8 b3 fe ff ff       	call   80102640 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010278d:	83 c4 10             	add    $0x10,%esp
80102790:	39 de                	cmp    %ebx,%esi
80102792:	73 e4                	jae    80102778 <kinit1+0x48>
}
80102794:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102797:	5b                   	pop    %ebx
80102798:	5e                   	pop    %esi
80102799:	5d                   	pop    %ebp
8010279a:	c3                   	ret    
8010279b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010279f:	90                   	nop

801027a0 <kinit2>:
{
801027a0:	f3 0f 1e fb          	endbr32 
801027a4:	55                   	push   %ebp
801027a5:	89 e5                	mov    %esp,%ebp
801027a7:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
801027a8:	8b 45 08             	mov    0x8(%ebp),%eax
{
801027ab:	8b 75 0c             	mov    0xc(%ebp),%esi
801027ae:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
801027af:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801027b5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027bb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801027c1:	39 de                	cmp    %ebx,%esi
801027c3:	72 1f                	jb     801027e4 <kinit2+0x44>
801027c5:	8d 76 00             	lea    0x0(%esi),%esi
    kfree(p);
801027c8:	83 ec 0c             	sub    $0xc,%esp
801027cb:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027d1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801027d7:	50                   	push   %eax
801027d8:	e8 63 fe ff ff       	call   80102640 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027dd:	83 c4 10             	add    $0x10,%esp
801027e0:	39 de                	cmp    %ebx,%esi
801027e2:	73 e4                	jae    801027c8 <kinit2+0x28>
  kmem.use_lock = 1;
801027e4:	c7 05 74 36 11 80 01 	movl   $0x1,0x80113674
801027eb:	00 00 00 
}
801027ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
801027f1:	5b                   	pop    %ebx
801027f2:	5e                   	pop    %esi
801027f3:	5d                   	pop    %ebp
801027f4:	c3                   	ret    
801027f5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801027fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102800 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102800:	f3 0f 1e fb          	endbr32 
  struct run *r;

  if(kmem.use_lock)
80102804:	a1 74 36 11 80       	mov    0x80113674,%eax
80102809:	85 c0                	test   %eax,%eax
8010280b:	75 1b                	jne    80102828 <kalloc+0x28>
    acquire(&kmem.lock);
  r = kmem.freelist;
8010280d:	a1 78 36 11 80       	mov    0x80113678,%eax
  if(r)
80102812:	85 c0                	test   %eax,%eax
80102814:	74 0a                	je     80102820 <kalloc+0x20>
    kmem.freelist = r->next;
80102816:	8b 10                	mov    (%eax),%edx
80102818:	89 15 78 36 11 80    	mov    %edx,0x80113678
  if(kmem.use_lock)
8010281e:	c3                   	ret    
8010281f:	90                   	nop
    release(&kmem.lock);
  return (char*)r;
}
80102820:	c3                   	ret    
80102821:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
{
80102828:	55                   	push   %ebp
80102829:	89 e5                	mov    %esp,%ebp
8010282b:	83 ec 24             	sub    $0x24,%esp
    acquire(&kmem.lock);
8010282e:	68 40 36 11 80       	push   $0x80113640
80102833:	e8 68 1e 00 00       	call   801046a0 <acquire>
  r = kmem.freelist;
80102838:	a1 78 36 11 80       	mov    0x80113678,%eax
  if(r)
8010283d:	8b 15 74 36 11 80    	mov    0x80113674,%edx
80102843:	83 c4 10             	add    $0x10,%esp
80102846:	85 c0                	test   %eax,%eax
80102848:	74 08                	je     80102852 <kalloc+0x52>
    kmem.freelist = r->next;
8010284a:	8b 08                	mov    (%eax),%ecx
8010284c:	89 0d 78 36 11 80    	mov    %ecx,0x80113678
  if(kmem.use_lock)
80102852:	85 d2                	test   %edx,%edx
80102854:	74 16                	je     8010286c <kalloc+0x6c>
    release(&kmem.lock);
80102856:	83 ec 0c             	sub    $0xc,%esp
80102859:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010285c:	68 40 36 11 80       	push   $0x80113640
80102861:	e8 6a 1f 00 00       	call   801047d0 <release>
  return (char*)r;
80102866:	8b 45 f4             	mov    -0xc(%ebp),%eax
    release(&kmem.lock);
80102869:	83 c4 10             	add    $0x10,%esp
}
8010286c:	c9                   	leave  
8010286d:	c3                   	ret    
8010286e:	66 90                	xchg   %ax,%ax

80102870 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102870:	f3 0f 1e fb          	endbr32 
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102874:	ba 64 00 00 00       	mov    $0x64,%edx
80102879:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
8010287a:	a8 01                	test   $0x1,%al
8010287c:	0f 84 be 00 00 00    	je     80102940 <kbdgetc+0xd0>
{
80102882:	55                   	push   %ebp
80102883:	ba 60 00 00 00       	mov    $0x60,%edx
80102888:	89 e5                	mov    %esp,%ebp
8010288a:	53                   	push   %ebx
8010288b:	ec                   	in     (%dx),%al
  return data;
8010288c:	8b 1d b4 b5 10 80    	mov    0x8010b5b4,%ebx
    return -1;
  data = inb(KBDATAP);
80102892:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
80102895:	3c e0                	cmp    $0xe0,%al
80102897:	74 57                	je     801028f0 <kbdgetc+0x80>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102899:	89 d9                	mov    %ebx,%ecx
8010289b:	83 e1 40             	and    $0x40,%ecx
8010289e:	84 c0                	test   %al,%al
801028a0:	78 5e                	js     80102900 <kbdgetc+0x90>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801028a2:	85 c9                	test   %ecx,%ecx
801028a4:	74 09                	je     801028af <kbdgetc+0x3f>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028a6:	83 c8 80             	or     $0xffffff80,%eax
    shift &= ~E0ESC;
801028a9:	83 e3 bf             	and    $0xffffffbf,%ebx
    data |= 0x80;
801028ac:	0f b6 d0             	movzbl %al,%edx
  }

  shift |= shiftcode[data];
801028af:	0f b6 8a e0 7d 10 80 	movzbl -0x7fef8220(%edx),%ecx
  shift ^= togglecode[data];
801028b6:	0f b6 82 e0 7c 10 80 	movzbl -0x7fef8320(%edx),%eax
  shift |= shiftcode[data];
801028bd:	09 d9                	or     %ebx,%ecx
  shift ^= togglecode[data];
801028bf:	31 c1                	xor    %eax,%ecx
  c = charcode[shift & (CTL | SHIFT)][data];
801028c1:	89 c8                	mov    %ecx,%eax
  shift ^= togglecode[data];
801028c3:	89 0d b4 b5 10 80    	mov    %ecx,0x8010b5b4
  c = charcode[shift & (CTL | SHIFT)][data];
801028c9:	83 e0 03             	and    $0x3,%eax
  if(shift & CAPSLOCK){
801028cc:	83 e1 08             	and    $0x8,%ecx
  c = charcode[shift & (CTL | SHIFT)][data];
801028cf:	8b 04 85 c0 7c 10 80 	mov    -0x7fef8340(,%eax,4),%eax
801028d6:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
801028da:	74 0b                	je     801028e7 <kbdgetc+0x77>
    if('a' <= c && c <= 'z')
801028dc:	8d 50 9f             	lea    -0x61(%eax),%edx
801028df:	83 fa 19             	cmp    $0x19,%edx
801028e2:	77 44                	ja     80102928 <kbdgetc+0xb8>
      c += 'A' - 'a';
801028e4:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801028e7:	5b                   	pop    %ebx
801028e8:	5d                   	pop    %ebp
801028e9:	c3                   	ret    
801028ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    shift |= E0ESC;
801028f0:	83 cb 40             	or     $0x40,%ebx
    return 0;
801028f3:	31 c0                	xor    %eax,%eax
    shift |= E0ESC;
801028f5:	89 1d b4 b5 10 80    	mov    %ebx,0x8010b5b4
}
801028fb:	5b                   	pop    %ebx
801028fc:	5d                   	pop    %ebp
801028fd:	c3                   	ret    
801028fe:	66 90                	xchg   %ax,%ax
    data = (shift & E0ESC ? data : data & 0x7F);
80102900:	83 e0 7f             	and    $0x7f,%eax
80102903:	85 c9                	test   %ecx,%ecx
80102905:	0f 44 d0             	cmove  %eax,%edx
    return 0;
80102908:	31 c0                	xor    %eax,%eax
    shift &= ~(shiftcode[data] | E0ESC);
8010290a:	0f b6 8a e0 7d 10 80 	movzbl -0x7fef8220(%edx),%ecx
80102911:	83 c9 40             	or     $0x40,%ecx
80102914:	0f b6 c9             	movzbl %cl,%ecx
80102917:	f7 d1                	not    %ecx
80102919:	21 d9                	and    %ebx,%ecx
}
8010291b:	5b                   	pop    %ebx
8010291c:	5d                   	pop    %ebp
    shift &= ~(shiftcode[data] | E0ESC);
8010291d:	89 0d b4 b5 10 80    	mov    %ecx,0x8010b5b4
}
80102923:	c3                   	ret    
80102924:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    else if('A' <= c && c <= 'Z')
80102928:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
8010292b:	8d 50 20             	lea    0x20(%eax),%edx
}
8010292e:	5b                   	pop    %ebx
8010292f:	5d                   	pop    %ebp
      c += 'a' - 'A';
80102930:	83 f9 1a             	cmp    $0x1a,%ecx
80102933:	0f 42 c2             	cmovb  %edx,%eax
}
80102936:	c3                   	ret    
80102937:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010293e:	66 90                	xchg   %ax,%ax
    return -1;
80102940:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102945:	c3                   	ret    
80102946:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010294d:	8d 76 00             	lea    0x0(%esi),%esi

80102950 <kbdintr>:

void
kbdintr(void)
{
80102950:	f3 0f 1e fb          	endbr32 
80102954:	55                   	push   %ebp
80102955:	89 e5                	mov    %esp,%ebp
80102957:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
8010295a:	68 70 28 10 80       	push   $0x80102870
8010295f:	e8 ec df ff ff       	call   80100950 <consoleintr>
}
80102964:	83 c4 10             	add    $0x10,%esp
80102967:	c9                   	leave  
80102968:	c3                   	ret    
80102969:	66 90                	xchg   %ax,%ax
8010296b:	66 90                	xchg   %ax,%ax
8010296d:	66 90                	xchg   %ax,%ax
8010296f:	90                   	nop

80102970 <lapicinit>:
  lapic[ID];  // wait for write to finish, by reading
}

void
lapicinit(void)
{
80102970:	f3 0f 1e fb          	endbr32 
  if(!lapic)
80102974:	a1 7c 36 11 80       	mov    0x8011367c,%eax
80102979:	85 c0                	test   %eax,%eax
8010297b:	0f 84 c7 00 00 00    	je     80102a48 <lapicinit+0xd8>
  lapic[index] = value;
80102981:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
80102988:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010298b:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010298e:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
80102995:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102998:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010299b:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
801029a2:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
801029a5:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029a8:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
801029af:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
801029b2:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029b5:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
801029bc:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
801029bf:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029c2:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
801029c9:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
801029cc:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801029cf:	8b 50 30             	mov    0x30(%eax),%edx
801029d2:	c1 ea 10             	shr    $0x10,%edx
801029d5:	81 e2 fc 00 00 00    	and    $0xfc,%edx
801029db:	75 73                	jne    80102a50 <lapicinit+0xe0>
  lapic[index] = value;
801029dd:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
801029e4:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801029e7:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029ea:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
801029f1:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801029f4:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029f7:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
801029fe:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a01:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a04:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102a0b:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a0e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a11:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
80102a18:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a1b:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a1e:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
80102a25:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
80102a28:	8b 50 20             	mov    0x20(%eax),%edx
80102a2b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102a2f:	90                   	nop
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
80102a30:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
80102a36:	80 e6 10             	and    $0x10,%dh
80102a39:	75 f5                	jne    80102a30 <lapicinit+0xc0>
  lapic[index] = value;
80102a3b:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80102a42:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a45:	8b 40 20             	mov    0x20(%eax),%eax
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102a48:	c3                   	ret    
80102a49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  lapic[index] = value;
80102a50:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
80102a57:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102a5a:	8b 50 20             	mov    0x20(%eax),%edx
}
80102a5d:	e9 7b ff ff ff       	jmp    801029dd <lapicinit+0x6d>
80102a62:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102a69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102a70 <lapicid>:

int
lapicid(void)
{
80102a70:	f3 0f 1e fb          	endbr32 
  if (!lapic)
80102a74:	a1 7c 36 11 80       	mov    0x8011367c,%eax
80102a79:	85 c0                	test   %eax,%eax
80102a7b:	74 0b                	je     80102a88 <lapicid+0x18>
    return 0;
  return lapic[ID] >> 24;
80102a7d:	8b 40 20             	mov    0x20(%eax),%eax
80102a80:	c1 e8 18             	shr    $0x18,%eax
80102a83:	c3                   	ret    
80102a84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return 0;
80102a88:	31 c0                	xor    %eax,%eax
}
80102a8a:	c3                   	ret    
80102a8b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102a8f:	90                   	nop

80102a90 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102a90:	f3 0f 1e fb          	endbr32 
  if(lapic)
80102a94:	a1 7c 36 11 80       	mov    0x8011367c,%eax
80102a99:	85 c0                	test   %eax,%eax
80102a9b:	74 0d                	je     80102aaa <lapiceoi+0x1a>
  lapic[index] = value;
80102a9d:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102aa4:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102aa7:	8b 40 20             	mov    0x20(%eax),%eax
    lapicw(EOI, 0);
}
80102aaa:	c3                   	ret    
80102aab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102aaf:	90                   	nop

80102ab0 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102ab0:	f3 0f 1e fb          	endbr32 
}
80102ab4:	c3                   	ret    
80102ab5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102abc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102ac0 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102ac0:	f3 0f 1e fb          	endbr32 
80102ac4:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ac5:	b8 0f 00 00 00       	mov    $0xf,%eax
80102aca:	ba 70 00 00 00       	mov    $0x70,%edx
80102acf:	89 e5                	mov    %esp,%ebp
80102ad1:	53                   	push   %ebx
80102ad2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102ad5:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102ad8:	ee                   	out    %al,(%dx)
80102ad9:	b8 0a 00 00 00       	mov    $0xa,%eax
80102ade:	ba 71 00 00 00       	mov    $0x71,%edx
80102ae3:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
80102ae4:	31 c0                	xor    %eax,%eax
  wrv[1] = addr >> 4;

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102ae6:	c1 e3 18             	shl    $0x18,%ebx
  wrv[0] = 0;
80102ae9:	66 a3 67 04 00 80    	mov    %ax,0x80000467
  wrv[1] = addr >> 4;
80102aef:	89 c8                	mov    %ecx,%eax
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
80102af1:	c1 e9 0c             	shr    $0xc,%ecx
  lapicw(ICRHI, apicid<<24);
80102af4:	89 da                	mov    %ebx,%edx
  wrv[1] = addr >> 4;
80102af6:	c1 e8 04             	shr    $0x4,%eax
    lapicw(ICRLO, STARTUP | (addr>>12));
80102af9:	80 cd 06             	or     $0x6,%ch
  wrv[1] = addr >> 4;
80102afc:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapic[index] = value;
80102b02:	a1 7c 36 11 80       	mov    0x8011367c,%eax
80102b07:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102b0d:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b10:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
80102b17:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b1a:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b1d:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
80102b24:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b27:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b2a:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102b30:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b33:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102b39:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b3c:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102b42:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b45:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
    microdelay(200);
  }
}
80102b4b:	5b                   	pop    %ebx
  lapic[ID];  // wait for write to finish, by reading
80102b4c:	8b 40 20             	mov    0x20(%eax),%eax
}
80102b4f:	5d                   	pop    %ebp
80102b50:	c3                   	ret    
80102b51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102b58:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102b5f:	90                   	nop

80102b60 <cmostime>:
  r->year   = cmos_read(YEAR);
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102b60:	f3 0f 1e fb          	endbr32 
80102b64:	55                   	push   %ebp
80102b65:	b8 0b 00 00 00       	mov    $0xb,%eax
80102b6a:	ba 70 00 00 00       	mov    $0x70,%edx
80102b6f:	89 e5                	mov    %esp,%ebp
80102b71:	57                   	push   %edi
80102b72:	56                   	push   %esi
80102b73:	53                   	push   %ebx
80102b74:	83 ec 4c             	sub    $0x4c,%esp
80102b77:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b78:	ba 71 00 00 00       	mov    $0x71,%edx
80102b7d:	ec                   	in     (%dx),%al
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);

  bcd = (sb & (1 << 2)) == 0;
80102b7e:	83 e0 04             	and    $0x4,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b81:	bb 70 00 00 00       	mov    $0x70,%ebx
80102b86:	88 45 b3             	mov    %al,-0x4d(%ebp)
80102b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102b90:	31 c0                	xor    %eax,%eax
80102b92:	89 da                	mov    %ebx,%edx
80102b94:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b95:	b9 71 00 00 00       	mov    $0x71,%ecx
80102b9a:	89 ca                	mov    %ecx,%edx
80102b9c:	ec                   	in     (%dx),%al
80102b9d:	88 45 b7             	mov    %al,-0x49(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ba0:	89 da                	mov    %ebx,%edx
80102ba2:	b8 02 00 00 00       	mov    $0x2,%eax
80102ba7:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ba8:	89 ca                	mov    %ecx,%edx
80102baa:	ec                   	in     (%dx),%al
80102bab:	88 45 b6             	mov    %al,-0x4a(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bae:	89 da                	mov    %ebx,%edx
80102bb0:	b8 04 00 00 00       	mov    $0x4,%eax
80102bb5:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bb6:	89 ca                	mov    %ecx,%edx
80102bb8:	ec                   	in     (%dx),%al
80102bb9:	88 45 b5             	mov    %al,-0x4b(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bbc:	89 da                	mov    %ebx,%edx
80102bbe:	b8 07 00 00 00       	mov    $0x7,%eax
80102bc3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bc4:	89 ca                	mov    %ecx,%edx
80102bc6:	ec                   	in     (%dx),%al
80102bc7:	88 45 b4             	mov    %al,-0x4c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bca:	89 da                	mov    %ebx,%edx
80102bcc:	b8 08 00 00 00       	mov    $0x8,%eax
80102bd1:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bd2:	89 ca                	mov    %ecx,%edx
80102bd4:	ec                   	in     (%dx),%al
80102bd5:	89 c7                	mov    %eax,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bd7:	89 da                	mov    %ebx,%edx
80102bd9:	b8 09 00 00 00       	mov    $0x9,%eax
80102bde:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bdf:	89 ca                	mov    %ecx,%edx
80102be1:	ec                   	in     (%dx),%al
80102be2:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102be4:	89 da                	mov    %ebx,%edx
80102be6:	b8 0a 00 00 00       	mov    $0xa,%eax
80102beb:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bec:	89 ca                	mov    %ecx,%edx
80102bee:	ec                   	in     (%dx),%al

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102bef:	84 c0                	test   %al,%al
80102bf1:	78 9d                	js     80102b90 <cmostime+0x30>
  return inb(CMOS_RETURN);
80102bf3:	0f b6 45 b7          	movzbl -0x49(%ebp),%eax
80102bf7:	89 fa                	mov    %edi,%edx
80102bf9:	0f b6 fa             	movzbl %dl,%edi
80102bfc:	89 f2                	mov    %esi,%edx
80102bfe:	89 45 b8             	mov    %eax,-0x48(%ebp)
80102c01:	0f b6 45 b6          	movzbl -0x4a(%ebp),%eax
80102c05:	0f b6 f2             	movzbl %dl,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c08:	89 da                	mov    %ebx,%edx
80102c0a:	89 7d c8             	mov    %edi,-0x38(%ebp)
80102c0d:	89 45 bc             	mov    %eax,-0x44(%ebp)
80102c10:	0f b6 45 b5          	movzbl -0x4b(%ebp),%eax
80102c14:	89 75 cc             	mov    %esi,-0x34(%ebp)
80102c17:	89 45 c0             	mov    %eax,-0x40(%ebp)
80102c1a:	0f b6 45 b4          	movzbl -0x4c(%ebp),%eax
80102c1e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102c21:	31 c0                	xor    %eax,%eax
80102c23:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c24:	89 ca                	mov    %ecx,%edx
80102c26:	ec                   	in     (%dx),%al
80102c27:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c2a:	89 da                	mov    %ebx,%edx
80102c2c:	89 45 d0             	mov    %eax,-0x30(%ebp)
80102c2f:	b8 02 00 00 00       	mov    $0x2,%eax
80102c34:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c35:	89 ca                	mov    %ecx,%edx
80102c37:	ec                   	in     (%dx),%al
80102c38:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c3b:	89 da                	mov    %ebx,%edx
80102c3d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80102c40:	b8 04 00 00 00       	mov    $0x4,%eax
80102c45:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c46:	89 ca                	mov    %ecx,%edx
80102c48:	ec                   	in     (%dx),%al
80102c49:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c4c:	89 da                	mov    %ebx,%edx
80102c4e:	89 45 d8             	mov    %eax,-0x28(%ebp)
80102c51:	b8 07 00 00 00       	mov    $0x7,%eax
80102c56:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c57:	89 ca                	mov    %ecx,%edx
80102c59:	ec                   	in     (%dx),%al
80102c5a:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c5d:	89 da                	mov    %ebx,%edx
80102c5f:	89 45 dc             	mov    %eax,-0x24(%ebp)
80102c62:	b8 08 00 00 00       	mov    $0x8,%eax
80102c67:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c68:	89 ca                	mov    %ecx,%edx
80102c6a:	ec                   	in     (%dx),%al
80102c6b:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c6e:	89 da                	mov    %ebx,%edx
80102c70:	89 45 e0             	mov    %eax,-0x20(%ebp)
80102c73:	b8 09 00 00 00       	mov    $0x9,%eax
80102c78:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c79:	89 ca                	mov    %ecx,%edx
80102c7b:	ec                   	in     (%dx),%al
80102c7c:	0f b6 c0             	movzbl %al,%eax
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102c7f:	83 ec 04             	sub    $0x4,%esp
  return inb(CMOS_RETURN);
80102c82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102c85:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102c88:	6a 18                	push   $0x18
80102c8a:	50                   	push   %eax
80102c8b:	8d 45 b8             	lea    -0x48(%ebp),%eax
80102c8e:	50                   	push   %eax
80102c8f:	e8 dc 1b 00 00       	call   80104870 <memcmp>
80102c94:	83 c4 10             	add    $0x10,%esp
80102c97:	85 c0                	test   %eax,%eax
80102c99:	0f 85 f1 fe ff ff    	jne    80102b90 <cmostime+0x30>
      break;
  }

  // convert
  if(bcd) {
80102c9f:	80 7d b3 00          	cmpb   $0x0,-0x4d(%ebp)
80102ca3:	75 78                	jne    80102d1d <cmostime+0x1bd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102ca5:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102ca8:	89 c2                	mov    %eax,%edx
80102caa:	83 e0 0f             	and    $0xf,%eax
80102cad:	c1 ea 04             	shr    $0x4,%edx
80102cb0:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102cb3:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102cb6:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
80102cb9:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102cbc:	89 c2                	mov    %eax,%edx
80102cbe:	83 e0 0f             	and    $0xf,%eax
80102cc1:	c1 ea 04             	shr    $0x4,%edx
80102cc4:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102cc7:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102cca:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
80102ccd:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102cd0:	89 c2                	mov    %eax,%edx
80102cd2:	83 e0 0f             	and    $0xf,%eax
80102cd5:	c1 ea 04             	shr    $0x4,%edx
80102cd8:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102cdb:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102cde:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102ce1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102ce4:	89 c2                	mov    %eax,%edx
80102ce6:	83 e0 0f             	and    $0xf,%eax
80102ce9:	c1 ea 04             	shr    $0x4,%edx
80102cec:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102cef:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102cf2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
80102cf5:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102cf8:	89 c2                	mov    %eax,%edx
80102cfa:	83 e0 0f             	and    $0xf,%eax
80102cfd:	c1 ea 04             	shr    $0x4,%edx
80102d00:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102d03:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102d06:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
80102d09:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102d0c:	89 c2                	mov    %eax,%edx
80102d0e:	83 e0 0f             	and    $0xf,%eax
80102d11:	c1 ea 04             	shr    $0x4,%edx
80102d14:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102d17:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102d1a:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
80102d1d:	8b 75 08             	mov    0x8(%ebp),%esi
80102d20:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102d23:	89 06                	mov    %eax,(%esi)
80102d25:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102d28:	89 46 04             	mov    %eax,0x4(%esi)
80102d2b:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102d2e:	89 46 08             	mov    %eax,0x8(%esi)
80102d31:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102d34:	89 46 0c             	mov    %eax,0xc(%esi)
80102d37:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102d3a:	89 46 10             	mov    %eax,0x10(%esi)
80102d3d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102d40:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102d43:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102d4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d4d:	5b                   	pop    %ebx
80102d4e:	5e                   	pop    %esi
80102d4f:	5f                   	pop    %edi
80102d50:	5d                   	pop    %ebp
80102d51:	c3                   	ret    
80102d52:	66 90                	xchg   %ax,%ax
80102d54:	66 90                	xchg   %ax,%ax
80102d56:	66 90                	xchg   %ax,%ax
80102d58:	66 90                	xchg   %ax,%ax
80102d5a:	66 90                	xchg   %ax,%ax
80102d5c:	66 90                	xchg   %ax,%ax
80102d5e:	66 90                	xchg   %ax,%ax

80102d60 <install_trans>:
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102d60:	8b 0d c8 36 11 80    	mov    0x801136c8,%ecx
80102d66:	85 c9                	test   %ecx,%ecx
80102d68:	0f 8e 8a 00 00 00    	jle    80102df8 <install_trans+0x98>
{
80102d6e:	55                   	push   %ebp
80102d6f:	89 e5                	mov    %esp,%ebp
80102d71:	57                   	push   %edi
  for (tail = 0; tail < log.lh.n; tail++) {
80102d72:	31 ff                	xor    %edi,%edi
{
80102d74:	56                   	push   %esi
80102d75:	53                   	push   %ebx
80102d76:	83 ec 0c             	sub    $0xc,%esp
80102d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102d80:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102d85:	83 ec 08             	sub    $0x8,%esp
80102d88:	01 f8                	add    %edi,%eax
80102d8a:	83 c0 01             	add    $0x1,%eax
80102d8d:	50                   	push   %eax
80102d8e:	ff 35 c4 36 11 80    	pushl  0x801136c4
80102d94:	e8 f7 d3 ff ff       	call   80100190 <bread>
80102d99:	89 c6                	mov    %eax,%esi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102d9b:	58                   	pop    %eax
80102d9c:	5a                   	pop    %edx
80102d9d:	ff 34 bd cc 36 11 80 	pushl  -0x7feec934(,%edi,4)
80102da4:	ff 35 c4 36 11 80    	pushl  0x801136c4
  for (tail = 0; tail < log.lh.n; tail++) {
80102daa:	83 c7 01             	add    $0x1,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102dad:	e8 de d3 ff ff       	call   80100190 <bread>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102db2:	83 c4 0c             	add    $0xc,%esp
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102db5:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102db7:	8d 46 5c             	lea    0x5c(%esi),%eax
80102dba:	68 00 02 00 00       	push   $0x200
80102dbf:	50                   	push   %eax
80102dc0:	8d 43 5c             	lea    0x5c(%ebx),%eax
80102dc3:	50                   	push   %eax
80102dc4:	e8 f7 1a 00 00       	call   801048c0 <memmove>
    bwrite(dbuf);  // write dst to disk
80102dc9:	89 1c 24             	mov    %ebx,(%esp)
80102dcc:	e8 ff d3 ff ff       	call   801001d0 <bwrite>
    brelse(lbuf);
80102dd1:	89 34 24             	mov    %esi,(%esp)
80102dd4:	e8 37 d4 ff ff       	call   80100210 <brelse>
    brelse(dbuf);
80102dd9:	89 1c 24             	mov    %ebx,(%esp)
80102ddc:	e8 2f d4 ff ff       	call   80100210 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102de1:	83 c4 10             	add    $0x10,%esp
80102de4:	39 3d c8 36 11 80    	cmp    %edi,0x801136c8
80102dea:	7f 94                	jg     80102d80 <install_trans+0x20>
  }
}
80102dec:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102def:	5b                   	pop    %ebx
80102df0:	5e                   	pop    %esi
80102df1:	5f                   	pop    %edi
80102df2:	5d                   	pop    %ebp
80102df3:	c3                   	ret    
80102df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102df8:	c3                   	ret    
80102df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102e00 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102e00:	55                   	push   %ebp
80102e01:	89 e5                	mov    %esp,%ebp
80102e03:	53                   	push   %ebx
80102e04:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102e07:	ff 35 b4 36 11 80    	pushl  0x801136b4
80102e0d:	ff 35 c4 36 11 80    	pushl  0x801136c4
80102e13:	e8 78 d3 ff ff       	call   80100190 <bread>
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80102e18:	83 c4 10             	add    $0x10,%esp
  struct buf *buf = bread(log.dev, log.start);
80102e1b:	89 c3                	mov    %eax,%ebx
  hb->n = log.lh.n;
80102e1d:	a1 c8 36 11 80       	mov    0x801136c8,%eax
80102e22:	89 43 5c             	mov    %eax,0x5c(%ebx)
  for (i = 0; i < log.lh.n; i++) {
80102e25:	85 c0                	test   %eax,%eax
80102e27:	7e 19                	jle    80102e42 <write_head+0x42>
80102e29:	31 d2                	xor    %edx,%edx
80102e2b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102e2f:	90                   	nop
    hb->block[i] = log.lh.block[i];
80102e30:	8b 0c 95 cc 36 11 80 	mov    -0x7feec934(,%edx,4),%ecx
80102e37:	89 4c 93 60          	mov    %ecx,0x60(%ebx,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102e3b:	83 c2 01             	add    $0x1,%edx
80102e3e:	39 d0                	cmp    %edx,%eax
80102e40:	75 ee                	jne    80102e30 <write_head+0x30>
  }
  bwrite(buf);
80102e42:	83 ec 0c             	sub    $0xc,%esp
80102e45:	53                   	push   %ebx
80102e46:	e8 85 d3 ff ff       	call   801001d0 <bwrite>
  brelse(buf);
80102e4b:	89 1c 24             	mov    %ebx,(%esp)
80102e4e:	e8 bd d3 ff ff       	call   80100210 <brelse>
}
80102e53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102e56:	83 c4 10             	add    $0x10,%esp
80102e59:	c9                   	leave  
80102e5a:	c3                   	ret    
80102e5b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102e5f:	90                   	nop

80102e60 <initlog>:
{
80102e60:	f3 0f 1e fb          	endbr32 
80102e64:	55                   	push   %ebp
80102e65:	89 e5                	mov    %esp,%ebp
80102e67:	53                   	push   %ebx
80102e68:	83 ec 2c             	sub    $0x2c,%esp
80102e6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102e6e:	68 e0 7e 10 80       	push   $0x80107ee0
80102e73:	68 80 36 11 80       	push   $0x80113680
80102e78:	e8 13 17 00 00       	call   80104590 <initlock>
  readsb(dev, &sb);
80102e7d:	58                   	pop    %eax
80102e7e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e81:	5a                   	pop    %edx
80102e82:	50                   	push   %eax
80102e83:	53                   	push   %ebx
80102e84:	e8 f7 e6 ff ff       	call   80101580 <readsb>
  log.start = sb.logstart;
80102e89:	8b 45 ec             	mov    -0x14(%ebp),%eax
  struct buf *buf = bread(log.dev, log.start);
80102e8c:	59                   	pop    %ecx
  log.dev = dev;
80102e8d:	89 1d c4 36 11 80    	mov    %ebx,0x801136c4
  log.size = sb.nlog;
80102e93:	8b 55 e8             	mov    -0x18(%ebp),%edx
  log.start = sb.logstart;
80102e96:	a3 b4 36 11 80       	mov    %eax,0x801136b4
  log.size = sb.nlog;
80102e9b:	89 15 b8 36 11 80    	mov    %edx,0x801136b8
  struct buf *buf = bread(log.dev, log.start);
80102ea1:	5a                   	pop    %edx
80102ea2:	50                   	push   %eax
80102ea3:	53                   	push   %ebx
80102ea4:	e8 e7 d2 ff ff       	call   80100190 <bread>
  for (i = 0; i < log.lh.n; i++) {
80102ea9:	83 c4 10             	add    $0x10,%esp
  log.lh.n = lh->n;
80102eac:	8b 48 5c             	mov    0x5c(%eax),%ecx
80102eaf:	89 0d c8 36 11 80    	mov    %ecx,0x801136c8
  for (i = 0; i < log.lh.n; i++) {
80102eb5:	85 c9                	test   %ecx,%ecx
80102eb7:	7e 19                	jle    80102ed2 <initlog+0x72>
80102eb9:	31 d2                	xor    %edx,%edx
80102ebb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102ebf:	90                   	nop
    log.lh.block[i] = lh->block[i];
80102ec0:	8b 5c 90 60          	mov    0x60(%eax,%edx,4),%ebx
80102ec4:	89 1c 95 cc 36 11 80 	mov    %ebx,-0x7feec934(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102ecb:	83 c2 01             	add    $0x1,%edx
80102ece:	39 d1                	cmp    %edx,%ecx
80102ed0:	75 ee                	jne    80102ec0 <initlog+0x60>
  brelse(buf);
80102ed2:	83 ec 0c             	sub    $0xc,%esp
80102ed5:	50                   	push   %eax
80102ed6:	e8 35 d3 ff ff       	call   80100210 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
80102edb:	e8 80 fe ff ff       	call   80102d60 <install_trans>
  log.lh.n = 0;
80102ee0:	c7 05 c8 36 11 80 00 	movl   $0x0,0x801136c8
80102ee7:	00 00 00 
  write_head(); // clear the log
80102eea:	e8 11 ff ff ff       	call   80102e00 <write_head>
}
80102eef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102ef2:	83 c4 10             	add    $0x10,%esp
80102ef5:	c9                   	leave  
80102ef6:	c3                   	ret    
80102ef7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102efe:	66 90                	xchg   %ax,%ax

80102f00 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
80102f00:	f3 0f 1e fb          	endbr32 
80102f04:	55                   	push   %ebp
80102f05:	89 e5                	mov    %esp,%ebp
80102f07:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102f0a:	68 80 36 11 80       	push   $0x80113680
80102f0f:	e8 8c 17 00 00       	call   801046a0 <acquire>
80102f14:	83 c4 10             	add    $0x10,%esp
80102f17:	eb 1c                	jmp    80102f35 <begin_op+0x35>
80102f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80102f20:	83 ec 08             	sub    $0x8,%esp
80102f23:	68 80 36 11 80       	push   $0x80113680
80102f28:	68 80 36 11 80       	push   $0x80113680
80102f2d:	e8 9e 11 00 00       	call   801040d0 <sleep>
80102f32:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102f35:	a1 c0 36 11 80       	mov    0x801136c0,%eax
80102f3a:	85 c0                	test   %eax,%eax
80102f3c:	75 e2                	jne    80102f20 <begin_op+0x20>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102f3e:	a1 bc 36 11 80       	mov    0x801136bc,%eax
80102f43:	8b 15 c8 36 11 80    	mov    0x801136c8,%edx
80102f49:	83 c0 01             	add    $0x1,%eax
80102f4c:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102f4f:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
80102f52:	83 fa 1e             	cmp    $0x1e,%edx
80102f55:	7f c9                	jg     80102f20 <begin_op+0x20>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
80102f57:	83 ec 0c             	sub    $0xc,%esp
      log.outstanding += 1;
80102f5a:	a3 bc 36 11 80       	mov    %eax,0x801136bc
      release(&log.lock);
80102f5f:	68 80 36 11 80       	push   $0x80113680
80102f64:	e8 67 18 00 00       	call   801047d0 <release>
      break;
    }
  }
}
80102f69:	83 c4 10             	add    $0x10,%esp
80102f6c:	c9                   	leave  
80102f6d:	c3                   	ret    
80102f6e:	66 90                	xchg   %ax,%ax

80102f70 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80102f70:	f3 0f 1e fb          	endbr32 
80102f74:	55                   	push   %ebp
80102f75:	89 e5                	mov    %esp,%ebp
80102f77:	57                   	push   %edi
80102f78:	56                   	push   %esi
80102f79:	53                   	push   %ebx
80102f7a:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;

  acquire(&log.lock);
80102f7d:	68 80 36 11 80       	push   $0x80113680
80102f82:	e8 19 17 00 00       	call   801046a0 <acquire>
  log.outstanding -= 1;
80102f87:	a1 bc 36 11 80       	mov    0x801136bc,%eax
  if(log.committing)
80102f8c:	8b 35 c0 36 11 80    	mov    0x801136c0,%esi
80102f92:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80102f95:	8d 58 ff             	lea    -0x1(%eax),%ebx
80102f98:	89 1d bc 36 11 80    	mov    %ebx,0x801136bc
  if(log.committing)
80102f9e:	85 f6                	test   %esi,%esi
80102fa0:	0f 85 1e 01 00 00    	jne    801030c4 <end_op+0x154>
    panic("log.committing");
  if(log.outstanding == 0){
80102fa6:	85 db                	test   %ebx,%ebx
80102fa8:	0f 85 f2 00 00 00    	jne    801030a0 <end_op+0x130>
    do_commit = 1;
    log.committing = 1;
80102fae:	c7 05 c0 36 11 80 01 	movl   $0x1,0x801136c0
80102fb5:	00 00 00 
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
80102fb8:	83 ec 0c             	sub    $0xc,%esp
80102fbb:	68 80 36 11 80       	push   $0x80113680
80102fc0:	e8 0b 18 00 00       	call   801047d0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
80102fc5:	8b 0d c8 36 11 80    	mov    0x801136c8,%ecx
80102fcb:	83 c4 10             	add    $0x10,%esp
80102fce:	85 c9                	test   %ecx,%ecx
80102fd0:	7f 3e                	jg     80103010 <end_op+0xa0>
    acquire(&log.lock);
80102fd2:	83 ec 0c             	sub    $0xc,%esp
80102fd5:	68 80 36 11 80       	push   $0x80113680
80102fda:	e8 c1 16 00 00       	call   801046a0 <acquire>
    wakeup(&log);
80102fdf:	c7 04 24 80 36 11 80 	movl   $0x80113680,(%esp)
    log.committing = 0;
80102fe6:	c7 05 c0 36 11 80 00 	movl   $0x0,0x801136c0
80102fed:	00 00 00 
    wakeup(&log);
80102ff0:	e8 ab 12 00 00       	call   801042a0 <wakeup>
    release(&log.lock);
80102ff5:	c7 04 24 80 36 11 80 	movl   $0x80113680,(%esp)
80102ffc:	e8 cf 17 00 00       	call   801047d0 <release>
80103001:	83 c4 10             	add    $0x10,%esp
}
80103004:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103007:	5b                   	pop    %ebx
80103008:	5e                   	pop    %esi
80103009:	5f                   	pop    %edi
8010300a:	5d                   	pop    %ebp
8010300b:	c3                   	ret    
8010300c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103010:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80103015:	83 ec 08             	sub    $0x8,%esp
80103018:	01 d8                	add    %ebx,%eax
8010301a:	83 c0 01             	add    $0x1,%eax
8010301d:	50                   	push   %eax
8010301e:	ff 35 c4 36 11 80    	pushl  0x801136c4
80103024:	e8 67 d1 ff ff       	call   80100190 <bread>
80103029:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010302b:	58                   	pop    %eax
8010302c:	5a                   	pop    %edx
8010302d:	ff 34 9d cc 36 11 80 	pushl  -0x7feec934(,%ebx,4)
80103034:	ff 35 c4 36 11 80    	pushl  0x801136c4
  for (tail = 0; tail < log.lh.n; tail++) {
8010303a:	83 c3 01             	add    $0x1,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010303d:	e8 4e d1 ff ff       	call   80100190 <bread>
    memmove(to->data, from->data, BSIZE);
80103042:	83 c4 0c             	add    $0xc,%esp
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103045:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80103047:	8d 40 5c             	lea    0x5c(%eax),%eax
8010304a:	68 00 02 00 00       	push   $0x200
8010304f:	50                   	push   %eax
80103050:	8d 46 5c             	lea    0x5c(%esi),%eax
80103053:	50                   	push   %eax
80103054:	e8 67 18 00 00       	call   801048c0 <memmove>
    bwrite(to);  // write the log
80103059:	89 34 24             	mov    %esi,(%esp)
8010305c:	e8 6f d1 ff ff       	call   801001d0 <bwrite>
    brelse(from);
80103061:	89 3c 24             	mov    %edi,(%esp)
80103064:	e8 a7 d1 ff ff       	call   80100210 <brelse>
    brelse(to);
80103069:	89 34 24             	mov    %esi,(%esp)
8010306c:	e8 9f d1 ff ff       	call   80100210 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80103071:	83 c4 10             	add    $0x10,%esp
80103074:	3b 1d c8 36 11 80    	cmp    0x801136c8,%ebx
8010307a:	7c 94                	jl     80103010 <end_op+0xa0>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
8010307c:	e8 7f fd ff ff       	call   80102e00 <write_head>
    install_trans(); // Now install writes to home locations
80103081:	e8 da fc ff ff       	call   80102d60 <install_trans>
    log.lh.n = 0;
80103086:	c7 05 c8 36 11 80 00 	movl   $0x0,0x801136c8
8010308d:	00 00 00 
    write_head();    // Erase the transaction from the log
80103090:	e8 6b fd ff ff       	call   80102e00 <write_head>
80103095:	e9 38 ff ff ff       	jmp    80102fd2 <end_op+0x62>
8010309a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&log);
801030a0:	83 ec 0c             	sub    $0xc,%esp
801030a3:	68 80 36 11 80       	push   $0x80113680
801030a8:	e8 f3 11 00 00       	call   801042a0 <wakeup>
  release(&log.lock);
801030ad:	c7 04 24 80 36 11 80 	movl   $0x80113680,(%esp)
801030b4:	e8 17 17 00 00       	call   801047d0 <release>
801030b9:	83 c4 10             	add    $0x10,%esp
}
801030bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801030bf:	5b                   	pop    %ebx
801030c0:	5e                   	pop    %esi
801030c1:	5f                   	pop    %edi
801030c2:	5d                   	pop    %ebp
801030c3:	c3                   	ret    
    panic("log.committing");
801030c4:	83 ec 0c             	sub    $0xc,%esp
801030c7:	68 e4 7e 10 80       	push   $0x80107ee4
801030cc:	e8 af d3 ff ff       	call   80100480 <panic>
801030d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801030d8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801030df:	90                   	nop

801030e0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801030e0:	f3 0f 1e fb          	endbr32 
801030e4:	55                   	push   %ebp
801030e5:	89 e5                	mov    %esp,%ebp
801030e7:	53                   	push   %ebx
801030e8:	83 ec 04             	sub    $0x4,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801030eb:	8b 15 c8 36 11 80    	mov    0x801136c8,%edx
{
801030f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801030f4:	83 fa 1d             	cmp    $0x1d,%edx
801030f7:	0f 8f 91 00 00 00    	jg     8010318e <log_write+0xae>
801030fd:	a1 b8 36 11 80       	mov    0x801136b8,%eax
80103102:	83 e8 01             	sub    $0x1,%eax
80103105:	39 c2                	cmp    %eax,%edx
80103107:	0f 8d 81 00 00 00    	jge    8010318e <log_write+0xae>
    panic("too big a transaction");
  if (log.outstanding < 1)
8010310d:	a1 bc 36 11 80       	mov    0x801136bc,%eax
80103112:	85 c0                	test   %eax,%eax
80103114:	0f 8e 81 00 00 00    	jle    8010319b <log_write+0xbb>
    panic("log_write outside of trans");

  acquire(&log.lock);
8010311a:	83 ec 0c             	sub    $0xc,%esp
8010311d:	68 80 36 11 80       	push   $0x80113680
80103122:	e8 79 15 00 00       	call   801046a0 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103127:	8b 15 c8 36 11 80    	mov    0x801136c8,%edx
8010312d:	83 c4 10             	add    $0x10,%esp
80103130:	85 d2                	test   %edx,%edx
80103132:	7e 4e                	jle    80103182 <log_write+0xa2>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103134:	8b 4b 08             	mov    0x8(%ebx),%ecx
  for (i = 0; i < log.lh.n; i++) {
80103137:	31 c0                	xor    %eax,%eax
80103139:	eb 0c                	jmp    80103147 <log_write+0x67>
8010313b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010313f:	90                   	nop
80103140:	83 c0 01             	add    $0x1,%eax
80103143:	39 c2                	cmp    %eax,%edx
80103145:	74 29                	je     80103170 <log_write+0x90>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103147:	39 0c 85 cc 36 11 80 	cmp    %ecx,-0x7feec934(,%eax,4)
8010314e:	75 f0                	jne    80103140 <log_write+0x60>
      break;
  }
  log.lh.block[i] = b->blockno;
80103150:	89 0c 85 cc 36 11 80 	mov    %ecx,-0x7feec934(,%eax,4)
  if (i == log.lh.n)
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80103157:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
}
8010315a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  release(&log.lock);
8010315d:	c7 45 08 80 36 11 80 	movl   $0x80113680,0x8(%ebp)
}
80103164:	c9                   	leave  
  release(&log.lock);
80103165:	e9 66 16 00 00       	jmp    801047d0 <release>
8010316a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  log.lh.block[i] = b->blockno;
80103170:	89 0c 95 cc 36 11 80 	mov    %ecx,-0x7feec934(,%edx,4)
    log.lh.n++;
80103177:	83 c2 01             	add    $0x1,%edx
8010317a:	89 15 c8 36 11 80    	mov    %edx,0x801136c8
80103180:	eb d5                	jmp    80103157 <log_write+0x77>
  log.lh.block[i] = b->blockno;
80103182:	8b 43 08             	mov    0x8(%ebx),%eax
80103185:	a3 cc 36 11 80       	mov    %eax,0x801136cc
  if (i == log.lh.n)
8010318a:	75 cb                	jne    80103157 <log_write+0x77>
8010318c:	eb e9                	jmp    80103177 <log_write+0x97>
    panic("too big a transaction");
8010318e:	83 ec 0c             	sub    $0xc,%esp
80103191:	68 f3 7e 10 80       	push   $0x80107ef3
80103196:	e8 e5 d2 ff ff       	call   80100480 <panic>
    panic("log_write outside of trans");
8010319b:	83 ec 0c             	sub    $0xc,%esp
8010319e:	68 09 7f 10 80       	push   $0x80107f09
801031a3:	e8 d8 d2 ff ff       	call   80100480 <panic>
801031a8:	66 90                	xchg   %ax,%ax
801031aa:	66 90                	xchg   %ax,%ax
801031ac:	66 90                	xchg   %ax,%ax
801031ae:	66 90                	xchg   %ax,%ax

801031b0 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801031b0:	55                   	push   %ebp
801031b1:	89 e5                	mov    %esp,%ebp
801031b3:	53                   	push   %ebx
801031b4:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801031b7:	e8 64 09 00 00       	call   80103b20 <cpuid>
801031bc:	89 c3                	mov    %eax,%ebx
801031be:	e8 5d 09 00 00       	call   80103b20 <cpuid>
801031c3:	83 ec 04             	sub    $0x4,%esp
801031c6:	53                   	push   %ebx
801031c7:	50                   	push   %eax
801031c8:	68 24 7f 10 80       	push   $0x80107f24
801031cd:	e8 ce d5 ff ff       	call   801007a0 <cprintf>
  idtinit();       // load idt register
801031d2:	e8 c9 29 00 00       	call   80105ba0 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801031d7:	e8 d4 08 00 00       	call   80103ab0 <mycpu>
801031dc:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801031de:	b8 01 00 00 00       	mov    $0x1,%eax
801031e3:	f0 87 82 a8 00 00 00 	lock xchg %eax,0xa8(%edx)
  scheduler();     // start running processes
801031ea:	e8 f1 0b 00 00       	call   80103de0 <scheduler>
801031ef:	90                   	nop

801031f0 <mpenter>:
{
801031f0:	f3 0f 1e fb          	endbr32 
801031f4:	55                   	push   %ebp
801031f5:	89 e5                	mov    %esp,%ebp
801031f7:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801031fa:	e8 f1 3e 00 00       	call   801070f0 <switchkvm>
  seginit();
801031ff:	e8 5c 3e 00 00       	call   80107060 <seginit>
  lapicinit();
80103204:	e8 67 f7 ff ff       	call   80102970 <lapicinit>
  mpmain();
80103209:	e8 a2 ff ff ff       	call   801031b0 <mpmain>
8010320e:	66 90                	xchg   %ax,%ax

80103210 <main>:
{
80103210:	f3 0f 1e fb          	endbr32 
80103214:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103218:	83 e4 f0             	and    $0xfffffff0,%esp
8010321b:	ff 71 fc             	pushl  -0x4(%ecx)
8010321e:	55                   	push   %ebp
8010321f:	89 e5                	mov    %esp,%ebp
80103221:	53                   	push   %ebx
80103222:	51                   	push   %ecx
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103223:	83 ec 08             	sub    $0x8,%esp
80103226:	68 00 00 40 80       	push   $0x80400000
8010322b:	68 08 86 11 80       	push   $0x80118608
80103230:	e8 fb f4 ff ff       	call   80102730 <kinit1>
  kvmalloc();      // kernel page table
80103235:	e8 76 43 00 00       	call   801075b0 <kvmalloc>
  mpinit();        // detect other processors
8010323a:	e8 81 01 00 00       	call   801033c0 <mpinit>
  lapicinit();     // interrupt controller
8010323f:	e8 2c f7 ff ff       	call   80102970 <lapicinit>
  seginit();       // segment descriptors
80103244:	e8 17 3e 00 00       	call   80107060 <seginit>
  picinit();       // disable pic
80103249:	e8 52 03 00 00       	call   801035a0 <picinit>
  ioapicinit();    // another interrupt controller
8010324e:	e8 fd f2 ff ff       	call   80102550 <ioapicinit>
  consoleinit();   // console hardware
80103253:	e8 c8 d8 ff ff       	call   80100b20 <consoleinit>
  uartinit();      // serial port
80103258:	e8 a3 30 00 00       	call   80106300 <uartinit>
  pinit();         // process table
8010325d:	e8 2e 08 00 00       	call   80103a90 <pinit>
  tvinit();        // trap vectors
80103262:	e8 b9 28 00 00       	call   80105b20 <tvinit>
  binit();         // buffer cache
80103267:	e8 94 ce ff ff       	call   80100100 <binit>
  fileinit();      // file table
8010326c:	e8 5f dc ff ff       	call   80100ed0 <fileinit>
  ideinit();       // disk 
80103271:	e8 aa f0 ff ff       	call   80102320 <ideinit>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103276:	83 c4 0c             	add    $0xc,%esp
80103279:	68 8a 00 00 00       	push   $0x8a
8010327e:	68 8c b4 10 80       	push   $0x8010b48c
80103283:	68 00 70 00 80       	push   $0x80007000
80103288:	e8 33 16 00 00       	call   801048c0 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010328d:	83 c4 10             	add    $0x10,%esp
80103290:	69 05 60 3d 11 80 bc 	imul   $0xbc,0x80113d60,%eax
80103297:	00 00 00 
8010329a:	05 80 37 11 80       	add    $0x80113780,%eax
8010329f:	3d 80 37 11 80       	cmp    $0x80113780,%eax
801032a4:	76 7a                	jbe    80103320 <main+0x110>
801032a6:	bb 80 37 11 80       	mov    $0x80113780,%ebx
801032ab:	eb 1c                	jmp    801032c9 <main+0xb9>
801032ad:	8d 76 00             	lea    0x0(%esi),%esi
801032b0:	69 05 60 3d 11 80 bc 	imul   $0xbc,0x80113d60,%eax
801032b7:	00 00 00 
801032ba:	81 c3 bc 00 00 00    	add    $0xbc,%ebx
801032c0:	05 80 37 11 80       	add    $0x80113780,%eax
801032c5:	39 c3                	cmp    %eax,%ebx
801032c7:	73 57                	jae    80103320 <main+0x110>
    if(c == mycpu())  // We've started already.
801032c9:	e8 e2 07 00 00       	call   80103ab0 <mycpu>
801032ce:	39 c3                	cmp    %eax,%ebx
801032d0:	74 de                	je     801032b0 <main+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801032d2:	e8 29 f5 ff ff       	call   80102800 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void**)(code-8) = mpenter;
    *(int**)(code-12) = (void *) V2P(entrypgdir);

    lapicstartap(c->apicid, V2P(code));
801032d7:	83 ec 08             	sub    $0x8,%esp
    *(void**)(code-8) = mpenter;
801032da:	c7 05 f8 6f 00 80 f0 	movl   $0x801031f0,0x80006ff8
801032e1:	31 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801032e4:	c7 05 f4 6f 00 80 00 	movl   $0x10a000,0x80006ff4
801032eb:	a0 10 00 
    *(void**)(code-4) = stack + KSTACKSIZE;
801032ee:	05 00 10 00 00       	add    $0x1000,%eax
801032f3:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    lapicstartap(c->apicid, V2P(code));
801032f8:	0f b6 03             	movzbl (%ebx),%eax
801032fb:	68 00 70 00 00       	push   $0x7000
80103300:	50                   	push   %eax
80103301:	e8 ba f7 ff ff       	call   80102ac0 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103306:	83 c4 10             	add    $0x10,%esp
80103309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103310:	8b 83 a8 00 00 00    	mov    0xa8(%ebx),%eax
80103316:	85 c0                	test   %eax,%eax
80103318:	74 f6                	je     80103310 <main+0x100>
8010331a:	eb 94                	jmp    801032b0 <main+0xa0>
8010331c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103320:	83 ec 08             	sub    $0x8,%esp
80103323:	68 00 00 40 80       	push   $0x80400000
80103328:	68 00 00 40 80       	push   $0x80400000
8010332d:	e8 6e f4 ff ff       	call   801027a0 <kinit2>
  userinit();      // first user process
80103332:	e8 39 08 00 00       	call   80103b70 <userinit>
  mpmain();        // finish this processor's setup
80103337:	e8 74 fe ff ff       	call   801031b0 <mpmain>
8010333c:	66 90                	xchg   %ax,%ax
8010333e:	66 90                	xchg   %ax,%ax

80103340 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103340:	55                   	push   %ebp
80103341:	89 e5                	mov    %esp,%ebp
80103343:	57                   	push   %edi
80103344:	56                   	push   %esi
  uchar *e, *p, *addr;

  addr = P2V(a);
80103345:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
{
8010334b:	53                   	push   %ebx
  e = addr+len;
8010334c:	8d 1c 16             	lea    (%esi,%edx,1),%ebx
{
8010334f:	83 ec 0c             	sub    $0xc,%esp
  for(p = addr; p < e; p += sizeof(struct mp))
80103352:	39 de                	cmp    %ebx,%esi
80103354:	72 10                	jb     80103366 <mpsearch1+0x26>
80103356:	eb 50                	jmp    801033a8 <mpsearch1+0x68>
80103358:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010335f:	90                   	nop
80103360:	89 fe                	mov    %edi,%esi
80103362:	39 fb                	cmp    %edi,%ebx
80103364:	76 42                	jbe    801033a8 <mpsearch1+0x68>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103366:	83 ec 04             	sub    $0x4,%esp
80103369:	8d 7e 10             	lea    0x10(%esi),%edi
8010336c:	6a 04                	push   $0x4
8010336e:	68 38 7f 10 80       	push   $0x80107f38
80103373:	56                   	push   %esi
80103374:	e8 f7 14 00 00       	call   80104870 <memcmp>
80103379:	83 c4 10             	add    $0x10,%esp
8010337c:	85 c0                	test   %eax,%eax
8010337e:	75 e0                	jne    80103360 <mpsearch1+0x20>
80103380:	89 f2                	mov    %esi,%edx
80103382:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    sum += addr[i];
80103388:	0f b6 0a             	movzbl (%edx),%ecx
8010338b:	83 c2 01             	add    $0x1,%edx
8010338e:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
80103390:	39 fa                	cmp    %edi,%edx
80103392:	75 f4                	jne    80103388 <mpsearch1+0x48>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103394:	84 c0                	test   %al,%al
80103396:	75 c8                	jne    80103360 <mpsearch1+0x20>
      return (struct mp*)p;
  return 0;
}
80103398:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010339b:	89 f0                	mov    %esi,%eax
8010339d:	5b                   	pop    %ebx
8010339e:	5e                   	pop    %esi
8010339f:	5f                   	pop    %edi
801033a0:	5d                   	pop    %ebp
801033a1:	c3                   	ret    
801033a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801033a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801033ab:	31 f6                	xor    %esi,%esi
}
801033ad:	5b                   	pop    %ebx
801033ae:	89 f0                	mov    %esi,%eax
801033b0:	5e                   	pop    %esi
801033b1:	5f                   	pop    %edi
801033b2:	5d                   	pop    %ebp
801033b3:	c3                   	ret    
801033b4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801033bb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801033bf:	90                   	nop

801033c0 <mpinit>:
  return conf;
}

void
mpinit(void)
{
801033c0:	f3 0f 1e fb          	endbr32 
801033c4:	55                   	push   %ebp
801033c5:	89 e5                	mov    %esp,%ebp
801033c7:	57                   	push   %edi
801033c8:	56                   	push   %esi
801033c9:	53                   	push   %ebx
801033ca:	83 ec 1c             	sub    $0x1c,%esp
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801033cd:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
801033d4:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
801033db:	c1 e0 08             	shl    $0x8,%eax
801033de:	09 d0                	or     %edx,%eax
801033e0:	c1 e0 04             	shl    $0x4,%eax
801033e3:	75 1b                	jne    80103400 <mpinit+0x40>
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
801033e5:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
801033ec:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
801033f3:	c1 e0 08             	shl    $0x8,%eax
801033f6:	09 d0                	or     %edx,%eax
801033f8:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
801033fb:	2d 00 04 00 00       	sub    $0x400,%eax
    if((mp = mpsearch1(p, 1024)))
80103400:	ba 00 04 00 00       	mov    $0x400,%edx
80103405:	e8 36 ff ff ff       	call   80103340 <mpsearch1>
8010340a:	89 c6                	mov    %eax,%esi
8010340c:	85 c0                	test   %eax,%eax
8010340e:	0f 84 4c 01 00 00    	je     80103560 <mpinit+0x1a0>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103414:	8b 5e 04             	mov    0x4(%esi),%ebx
80103417:	85 db                	test   %ebx,%ebx
80103419:	0f 84 61 01 00 00    	je     80103580 <mpinit+0x1c0>
  if(memcmp(conf, "PCMP", 4) != 0)
8010341f:	83 ec 04             	sub    $0x4,%esp
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103422:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
  if(memcmp(conf, "PCMP", 4) != 0)
80103428:	6a 04                	push   $0x4
8010342a:	68 3d 7f 10 80       	push   $0x80107f3d
8010342f:	50                   	push   %eax
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103430:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103433:	e8 38 14 00 00       	call   80104870 <memcmp>
80103438:	83 c4 10             	add    $0x10,%esp
8010343b:	85 c0                	test   %eax,%eax
8010343d:	0f 85 3d 01 00 00    	jne    80103580 <mpinit+0x1c0>
  if(conf->version != 1 && conf->version != 4)
80103443:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
8010344a:	3c 01                	cmp    $0x1,%al
8010344c:	74 08                	je     80103456 <mpinit+0x96>
8010344e:	3c 04                	cmp    $0x4,%al
80103450:	0f 85 2a 01 00 00    	jne    80103580 <mpinit+0x1c0>
  if(sum((uchar*)conf, conf->length) != 0)
80103456:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
  for(i=0; i<len; i++)
8010345d:	66 85 d2             	test   %dx,%dx
80103460:	74 26                	je     80103488 <mpinit+0xc8>
80103462:	8d 3c 1a             	lea    (%edx,%ebx,1),%edi
80103465:	89 d8                	mov    %ebx,%eax
  sum = 0;
80103467:	31 d2                	xor    %edx,%edx
80103469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    sum += addr[i];
80103470:	0f b6 88 00 00 00 80 	movzbl -0x80000000(%eax),%ecx
80103477:	83 c0 01             	add    $0x1,%eax
8010347a:	01 ca                	add    %ecx,%edx
  for(i=0; i<len; i++)
8010347c:	39 f8                	cmp    %edi,%eax
8010347e:	75 f0                	jne    80103470 <mpinit+0xb0>
  if(sum((uchar*)conf, conf->length) != 0)
80103480:	84 d2                	test   %dl,%dl
80103482:	0f 85 f8 00 00 00    	jne    80103580 <mpinit+0x1c0>
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80103488:	8b 83 24 00 00 80    	mov    -0x7fffffdc(%ebx),%eax
8010348e:	a3 7c 36 11 80       	mov    %eax,0x8011367c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103493:	8d 83 2c 00 00 80    	lea    -0x7fffffd4(%ebx),%eax
80103499:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
  ismp = 1;
801034a0:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801034a5:	03 55 e4             	add    -0x1c(%ebp),%edx
801034a8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801034ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801034af:	90                   	nop
801034b0:	39 c2                	cmp    %eax,%edx
801034b2:	76 15                	jbe    801034c9 <mpinit+0x109>
    switch(*p){
801034b4:	0f b6 08             	movzbl (%eax),%ecx
801034b7:	80 f9 02             	cmp    $0x2,%cl
801034ba:	74 5c                	je     80103518 <mpinit+0x158>
801034bc:	77 42                	ja     80103500 <mpinit+0x140>
801034be:	84 c9                	test   %cl,%cl
801034c0:	74 6e                	je     80103530 <mpinit+0x170>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801034c2:	83 c0 08             	add    $0x8,%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801034c5:	39 c2                	cmp    %eax,%edx
801034c7:	77 eb                	ja     801034b4 <mpinit+0xf4>
801034c9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
801034cc:	85 db                	test   %ebx,%ebx
801034ce:	0f 84 b9 00 00 00    	je     8010358d <mpinit+0x1cd>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
801034d4:	80 7e 0c 00          	cmpb   $0x0,0xc(%esi)
801034d8:	74 15                	je     801034ef <mpinit+0x12f>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801034da:	b8 70 00 00 00       	mov    $0x70,%eax
801034df:	ba 22 00 00 00       	mov    $0x22,%edx
801034e4:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801034e5:	ba 23 00 00 00       	mov    $0x23,%edx
801034ea:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801034eb:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801034ee:	ee                   	out    %al,(%dx)
  }
}
801034ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
801034f2:	5b                   	pop    %ebx
801034f3:	5e                   	pop    %esi
801034f4:	5f                   	pop    %edi
801034f5:	5d                   	pop    %ebp
801034f6:	c3                   	ret    
801034f7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801034fe:	66 90                	xchg   %ax,%ax
    switch(*p){
80103500:	83 e9 03             	sub    $0x3,%ecx
80103503:	80 f9 01             	cmp    $0x1,%cl
80103506:	76 ba                	jbe    801034c2 <mpinit+0x102>
80103508:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010350f:	eb 9f                	jmp    801034b0 <mpinit+0xf0>
80103511:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      ioapicid = ioapic->apicno;
80103518:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
      p += sizeof(struct mpioapic);
8010351c:	83 c0 08             	add    $0x8,%eax
      ioapicid = ioapic->apicno;
8010351f:	88 0d 60 37 11 80    	mov    %cl,0x80113760
      continue;
80103525:	eb 89                	jmp    801034b0 <mpinit+0xf0>
80103527:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010352e:	66 90                	xchg   %ax,%ax
      if(ncpu < NCPU) {
80103530:	8b 0d 60 3d 11 80    	mov    0x80113d60,%ecx
80103536:	83 f9 07             	cmp    $0x7,%ecx
80103539:	7f 19                	jg     80103554 <mpinit+0x194>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010353b:	69 f9 bc 00 00 00    	imul   $0xbc,%ecx,%edi
80103541:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
        ncpu++;
80103545:	83 c1 01             	add    $0x1,%ecx
80103548:	89 0d 60 3d 11 80    	mov    %ecx,0x80113d60
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010354e:	88 9f 80 37 11 80    	mov    %bl,-0x7feec880(%edi)
      p += sizeof(struct mpproc);
80103554:	83 c0 14             	add    $0x14,%eax
      continue;
80103557:	e9 54 ff ff ff       	jmp    801034b0 <mpinit+0xf0>
8010355c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  return mpsearch1(0xF0000, 0x10000);
80103560:	ba 00 00 01 00       	mov    $0x10000,%edx
80103565:	b8 00 00 0f 00       	mov    $0xf0000,%eax
8010356a:	e8 d1 fd ff ff       	call   80103340 <mpsearch1>
8010356f:	89 c6                	mov    %eax,%esi
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103571:	85 c0                	test   %eax,%eax
80103573:	0f 85 9b fe ff ff    	jne    80103414 <mpinit+0x54>
80103579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    panic("Expect to run on an SMP");
80103580:	83 ec 0c             	sub    $0xc,%esp
80103583:	68 42 7f 10 80       	push   $0x80107f42
80103588:	e8 f3 ce ff ff       	call   80100480 <panic>
    panic("Didn't find a suitable machine");
8010358d:	83 ec 0c             	sub    $0xc,%esp
80103590:	68 5c 7f 10 80       	push   $0x80107f5c
80103595:	e8 e6 ce ff ff       	call   80100480 <panic>
8010359a:	66 90                	xchg   %ax,%ax
8010359c:	66 90                	xchg   %ax,%ax
8010359e:	66 90                	xchg   %ax,%ax

801035a0 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
801035a0:	f3 0f 1e fb          	endbr32 
801035a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801035a9:	ba 21 00 00 00       	mov    $0x21,%edx
801035ae:	ee                   	out    %al,(%dx)
801035af:	ba a1 00 00 00       	mov    $0xa1,%edx
801035b4:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
801035b5:	c3                   	ret    
801035b6:	66 90                	xchg   %ax,%ax
801035b8:	66 90                	xchg   %ax,%ax
801035ba:	66 90                	xchg   %ax,%ax
801035bc:	66 90                	xchg   %ax,%ax
801035be:	66 90                	xchg   %ax,%ax

801035c0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801035c0:	f3 0f 1e fb          	endbr32 
801035c4:	55                   	push   %ebp
801035c5:	89 e5                	mov    %esp,%ebp
801035c7:	57                   	push   %edi
801035c8:	56                   	push   %esi
801035c9:	53                   	push   %ebx
801035ca:	83 ec 0c             	sub    $0xc,%esp
801035cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
801035d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
801035d3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801035d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801035df:	e8 0c d9 ff ff       	call   80100ef0 <filealloc>
801035e4:	89 03                	mov    %eax,(%ebx)
801035e6:	85 c0                	test   %eax,%eax
801035e8:	0f 84 ac 00 00 00    	je     8010369a <pipealloc+0xda>
801035ee:	e8 fd d8 ff ff       	call   80100ef0 <filealloc>
801035f3:	89 06                	mov    %eax,(%esi)
801035f5:	85 c0                	test   %eax,%eax
801035f7:	0f 84 8b 00 00 00    	je     80103688 <pipealloc+0xc8>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035fd:	e8 fe f1 ff ff       	call   80102800 <kalloc>
80103602:	89 c7                	mov    %eax,%edi
80103604:	85 c0                	test   %eax,%eax
80103606:	0f 84 b4 00 00 00    	je     801036c0 <pipealloc+0x100>
    goto bad;
  p->readopen = 1;
8010360c:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103613:	00 00 00 
  p->writeopen = 1;
  p->nwrite = 0;
  p->nread = 0;
  initlock(&p->lock, "pipe");
80103616:	83 ec 08             	sub    $0x8,%esp
  p->writeopen = 1;
80103619:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103620:	00 00 00 
  p->nwrite = 0;
80103623:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010362a:	00 00 00 
  p->nread = 0;
8010362d:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103634:	00 00 00 
  initlock(&p->lock, "pipe");
80103637:	68 7b 7f 10 80       	push   $0x80107f7b
8010363c:	50                   	push   %eax
8010363d:	e8 4e 0f 00 00       	call   80104590 <initlock>
  (*f0)->type = FD_PIPE;
80103642:	8b 03                	mov    (%ebx),%eax
  (*f0)->pipe = p;
  (*f1)->type = FD_PIPE;
  (*f1)->readable = 0;
  (*f1)->writable = 1;
  (*f1)->pipe = p;
  return 0;
80103644:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103647:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010364d:	8b 03                	mov    (%ebx),%eax
8010364f:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103653:	8b 03                	mov    (%ebx),%eax
80103655:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103659:	8b 03                	mov    (%ebx),%eax
8010365b:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010365e:	8b 06                	mov    (%esi),%eax
80103660:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103666:	8b 06                	mov    (%esi),%eax
80103668:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010366c:	8b 06                	mov    (%esi),%eax
8010366e:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103672:	8b 06                	mov    (%esi),%eax
80103674:	89 78 0c             	mov    %edi,0xc(%eax)
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
80103677:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
8010367a:	31 c0                	xor    %eax,%eax
}
8010367c:	5b                   	pop    %ebx
8010367d:	5e                   	pop    %esi
8010367e:	5f                   	pop    %edi
8010367f:	5d                   	pop    %ebp
80103680:	c3                   	ret    
80103681:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(*f0)
80103688:	8b 03                	mov    (%ebx),%eax
8010368a:	85 c0                	test   %eax,%eax
8010368c:	74 1e                	je     801036ac <pipealloc+0xec>
    fileclose(*f0);
8010368e:	83 ec 0c             	sub    $0xc,%esp
80103691:	50                   	push   %eax
80103692:	e8 19 d9 ff ff       	call   80100fb0 <fileclose>
80103697:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010369a:	8b 06                	mov    (%esi),%eax
8010369c:	85 c0                	test   %eax,%eax
8010369e:	74 0c                	je     801036ac <pipealloc+0xec>
    fileclose(*f1);
801036a0:	83 ec 0c             	sub    $0xc,%esp
801036a3:	50                   	push   %eax
801036a4:	e8 07 d9 ff ff       	call   80100fb0 <fileclose>
801036a9:	83 c4 10             	add    $0x10,%esp
}
801036ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
801036af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036b4:	5b                   	pop    %ebx
801036b5:	5e                   	pop    %esi
801036b6:	5f                   	pop    %edi
801036b7:	5d                   	pop    %ebp
801036b8:	c3                   	ret    
801036b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(*f0)
801036c0:	8b 03                	mov    (%ebx),%eax
801036c2:	85 c0                	test   %eax,%eax
801036c4:	75 c8                	jne    8010368e <pipealloc+0xce>
801036c6:	eb d2                	jmp    8010369a <pipealloc+0xda>
801036c8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801036cf:	90                   	nop

801036d0 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036d0:	f3 0f 1e fb          	endbr32 
801036d4:	55                   	push   %ebp
801036d5:	89 e5                	mov    %esp,%ebp
801036d7:	56                   	push   %esi
801036d8:	53                   	push   %ebx
801036d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
801036dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
801036df:	83 ec 0c             	sub    $0xc,%esp
801036e2:	53                   	push   %ebx
801036e3:	e8 b8 0f 00 00       	call   801046a0 <acquire>
  if(writable){
801036e8:	83 c4 10             	add    $0x10,%esp
801036eb:	85 f6                	test   %esi,%esi
801036ed:	74 41                	je     80103730 <pipeclose+0x60>
    p->writeopen = 0;
    wakeup(&p->nread);
801036ef:	83 ec 0c             	sub    $0xc,%esp
801036f2:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
    p->writeopen = 0;
801036f8:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
801036ff:	00 00 00 
    wakeup(&p->nread);
80103702:	50                   	push   %eax
80103703:	e8 98 0b 00 00       	call   801042a0 <wakeup>
80103708:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010370b:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
80103711:	85 d2                	test   %edx,%edx
80103713:	75 0a                	jne    8010371f <pipeclose+0x4f>
80103715:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
8010371b:	85 c0                	test   %eax,%eax
8010371d:	74 31                	je     80103750 <pipeclose+0x80>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
8010371f:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80103722:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103725:	5b                   	pop    %ebx
80103726:	5e                   	pop    %esi
80103727:	5d                   	pop    %ebp
    release(&p->lock);
80103728:	e9 a3 10 00 00       	jmp    801047d0 <release>
8010372d:	8d 76 00             	lea    0x0(%esi),%esi
    wakeup(&p->nwrite);
80103730:	83 ec 0c             	sub    $0xc,%esp
80103733:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
    p->readopen = 0;
80103739:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103740:	00 00 00 
    wakeup(&p->nwrite);
80103743:	50                   	push   %eax
80103744:	e8 57 0b 00 00       	call   801042a0 <wakeup>
80103749:	83 c4 10             	add    $0x10,%esp
8010374c:	eb bd                	jmp    8010370b <pipeclose+0x3b>
8010374e:	66 90                	xchg   %ax,%ax
    release(&p->lock);
80103750:	83 ec 0c             	sub    $0xc,%esp
80103753:	53                   	push   %ebx
80103754:	e8 77 10 00 00       	call   801047d0 <release>
    kfree((char*)p);
80103759:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010375c:	83 c4 10             	add    $0x10,%esp
}
8010375f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103762:	5b                   	pop    %ebx
80103763:	5e                   	pop    %esi
80103764:	5d                   	pop    %ebp
    kfree((char*)p);
80103765:	e9 d6 ee ff ff       	jmp    80102640 <kfree>
8010376a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103770 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103770:	f3 0f 1e fb          	endbr32 
80103774:	55                   	push   %ebp
80103775:	89 e5                	mov    %esp,%ebp
80103777:	57                   	push   %edi
80103778:	56                   	push   %esi
80103779:	53                   	push   %ebx
8010377a:	83 ec 28             	sub    $0x28,%esp
8010377d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80103780:	53                   	push   %ebx
80103781:	e8 1a 0f 00 00       	call   801046a0 <acquire>
  for(i = 0; i < n; i++){
80103786:	8b 45 10             	mov    0x10(%ebp),%eax
80103789:	83 c4 10             	add    $0x10,%esp
8010378c:	85 c0                	test   %eax,%eax
8010378e:	0f 8e bc 00 00 00    	jle    80103850 <pipewrite+0xe0>
80103794:	8b 45 0c             	mov    0xc(%ebp),%eax
80103797:	8b 8b 38 02 00 00    	mov    0x238(%ebx),%ecx
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
8010379d:	8d bb 34 02 00 00    	lea    0x234(%ebx),%edi
801037a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801037a6:	03 45 10             	add    0x10(%ebp),%eax
801037a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037ac:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037b2:	8d b3 38 02 00 00    	lea    0x238(%ebx),%esi
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037b8:	89 ca                	mov    %ecx,%edx
801037ba:	05 00 02 00 00       	add    $0x200,%eax
801037bf:	39 c1                	cmp    %eax,%ecx
801037c1:	74 3b                	je     801037fe <pipewrite+0x8e>
801037c3:	eb 63                	jmp    80103828 <pipewrite+0xb8>
801037c5:	8d 76 00             	lea    0x0(%esi),%esi
      if(p->readopen == 0 || myproc()->killed){
801037c8:	e8 73 03 00 00       	call   80103b40 <myproc>
801037cd:	8b 48 24             	mov    0x24(%eax),%ecx
801037d0:	85 c9                	test   %ecx,%ecx
801037d2:	75 34                	jne    80103808 <pipewrite+0x98>
      wakeup(&p->nread);
801037d4:	83 ec 0c             	sub    $0xc,%esp
801037d7:	57                   	push   %edi
801037d8:	e8 c3 0a 00 00       	call   801042a0 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037dd:	58                   	pop    %eax
801037de:	5a                   	pop    %edx
801037df:	53                   	push   %ebx
801037e0:	56                   	push   %esi
801037e1:	e8 ea 08 00 00       	call   801040d0 <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037e6:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
801037ec:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
801037f2:	83 c4 10             	add    $0x10,%esp
801037f5:	05 00 02 00 00       	add    $0x200,%eax
801037fa:	39 c2                	cmp    %eax,%edx
801037fc:	75 2a                	jne    80103828 <pipewrite+0xb8>
      if(p->readopen == 0 || myproc()->killed){
801037fe:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
80103804:	85 c0                	test   %eax,%eax
80103806:	75 c0                	jne    801037c8 <pipewrite+0x58>
        release(&p->lock);
80103808:	83 ec 0c             	sub    $0xc,%esp
8010380b:	53                   	push   %ebx
8010380c:	e8 bf 0f 00 00       	call   801047d0 <release>
        return -1;
80103811:	83 c4 10             	add    $0x10,%esp
80103814:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103819:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010381c:	5b                   	pop    %ebx
8010381d:	5e                   	pop    %esi
8010381e:	5f                   	pop    %edi
8010381f:	5d                   	pop    %ebp
80103820:	c3                   	ret    
80103821:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103828:	8b 75 e4             	mov    -0x1c(%ebp),%esi
8010382b:	8d 4a 01             	lea    0x1(%edx),%ecx
8010382e:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80103834:	89 8b 38 02 00 00    	mov    %ecx,0x238(%ebx)
8010383a:	0f b6 06             	movzbl (%esi),%eax
8010383d:	83 c6 01             	add    $0x1,%esi
80103840:	89 75 e4             	mov    %esi,-0x1c(%ebp)
80103843:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80103847:	3b 75 e0             	cmp    -0x20(%ebp),%esi
8010384a:	0f 85 5c ff ff ff    	jne    801037ac <pipewrite+0x3c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103850:	83 ec 0c             	sub    $0xc,%esp
80103853:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103859:	50                   	push   %eax
8010385a:	e8 41 0a 00 00       	call   801042a0 <wakeup>
  release(&p->lock);
8010385f:	89 1c 24             	mov    %ebx,(%esp)
80103862:	e8 69 0f 00 00       	call   801047d0 <release>
  return n;
80103867:	8b 45 10             	mov    0x10(%ebp),%eax
8010386a:	83 c4 10             	add    $0x10,%esp
8010386d:	eb aa                	jmp    80103819 <pipewrite+0xa9>
8010386f:	90                   	nop

80103870 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103870:	f3 0f 1e fb          	endbr32 
80103874:	55                   	push   %ebp
80103875:	89 e5                	mov    %esp,%ebp
80103877:	57                   	push   %edi
80103878:	56                   	push   %esi
80103879:	53                   	push   %ebx
8010387a:	83 ec 18             	sub    $0x18,%esp
8010387d:	8b 75 08             	mov    0x8(%ebp),%esi
80103880:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
80103883:	56                   	push   %esi
80103884:	8d 9e 34 02 00 00    	lea    0x234(%esi),%ebx
8010388a:	e8 11 0e 00 00       	call   801046a0 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010388f:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103895:	83 c4 10             	add    $0x10,%esp
80103898:	39 86 38 02 00 00    	cmp    %eax,0x238(%esi)
8010389e:	74 33                	je     801038d3 <piperead+0x63>
801038a0:	eb 3b                	jmp    801038dd <piperead+0x6d>
801038a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(myproc()->killed){
801038a8:	e8 93 02 00 00       	call   80103b40 <myproc>
801038ad:	8b 48 24             	mov    0x24(%eax),%ecx
801038b0:	85 c9                	test   %ecx,%ecx
801038b2:	0f 85 88 00 00 00    	jne    80103940 <piperead+0xd0>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038b8:	83 ec 08             	sub    $0x8,%esp
801038bb:	56                   	push   %esi
801038bc:	53                   	push   %ebx
801038bd:	e8 0e 08 00 00       	call   801040d0 <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038c2:	8b 86 38 02 00 00    	mov    0x238(%esi),%eax
801038c8:	83 c4 10             	add    $0x10,%esp
801038cb:	39 86 34 02 00 00    	cmp    %eax,0x234(%esi)
801038d1:	75 0a                	jne    801038dd <piperead+0x6d>
801038d3:	8b 86 40 02 00 00    	mov    0x240(%esi),%eax
801038d9:	85 c0                	test   %eax,%eax
801038db:	75 cb                	jne    801038a8 <piperead+0x38>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038dd:	8b 55 10             	mov    0x10(%ebp),%edx
801038e0:	31 db                	xor    %ebx,%ebx
801038e2:	85 d2                	test   %edx,%edx
801038e4:	7f 28                	jg     8010390e <piperead+0x9e>
801038e6:	eb 34                	jmp    8010391c <piperead+0xac>
801038e8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801038ef:	90                   	nop
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801038f0:	8d 48 01             	lea    0x1(%eax),%ecx
801038f3:	25 ff 01 00 00       	and    $0x1ff,%eax
801038f8:	89 8e 34 02 00 00    	mov    %ecx,0x234(%esi)
801038fe:	0f b6 44 06 34       	movzbl 0x34(%esi,%eax,1),%eax
80103903:	88 04 1f             	mov    %al,(%edi,%ebx,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103906:	83 c3 01             	add    $0x1,%ebx
80103909:	39 5d 10             	cmp    %ebx,0x10(%ebp)
8010390c:	74 0e                	je     8010391c <piperead+0xac>
    if(p->nread == p->nwrite)
8010390e:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103914:	3b 86 38 02 00 00    	cmp    0x238(%esi),%eax
8010391a:	75 d4                	jne    801038f0 <piperead+0x80>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010391c:	83 ec 0c             	sub    $0xc,%esp
8010391f:	8d 86 38 02 00 00    	lea    0x238(%esi),%eax
80103925:	50                   	push   %eax
80103926:	e8 75 09 00 00       	call   801042a0 <wakeup>
  release(&p->lock);
8010392b:	89 34 24             	mov    %esi,(%esp)
8010392e:	e8 9d 0e 00 00       	call   801047d0 <release>
  return i;
80103933:	83 c4 10             	add    $0x10,%esp
}
80103936:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103939:	89 d8                	mov    %ebx,%eax
8010393b:	5b                   	pop    %ebx
8010393c:	5e                   	pop    %esi
8010393d:	5f                   	pop    %edi
8010393e:	5d                   	pop    %ebp
8010393f:	c3                   	ret    
      release(&p->lock);
80103940:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80103943:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
      release(&p->lock);
80103948:	56                   	push   %esi
80103949:	e8 82 0e 00 00       	call   801047d0 <release>
      return -1;
8010394e:	83 c4 10             	add    $0x10,%esp
}
80103951:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103954:	89 d8                	mov    %ebx,%eax
80103956:	5b                   	pop    %ebx
80103957:	5e                   	pop    %esi
80103958:	5f                   	pop    %edi
80103959:	5d                   	pop    %ebp
8010395a:	c3                   	ret    
8010395b:	66 90                	xchg   %ax,%ax
8010395d:	66 90                	xchg   %ax,%ax
8010395f:	90                   	nop

80103960 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103960:	55                   	push   %ebp
80103961:	89 e5                	mov    %esp,%ebp
80103963:	53                   	push   %ebx
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103964:	bb b4 3d 11 80       	mov    $0x80113db4,%ebx
{
80103969:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
8010396c:	68 80 3d 11 80       	push   $0x80113d80
80103971:	e8 2a 0d 00 00       	call   801046a0 <acquire>
80103976:	83 c4 10             	add    $0x10,%esp
80103979:	eb 13                	jmp    8010398e <allocproc+0x2e>
8010397b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010397f:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103980:	81 c3 00 01 00 00    	add    $0x100,%ebx
80103986:	81 fb b4 7d 11 80    	cmp    $0x80117db4,%ebx
8010398c:	74 7a                	je     80103a08 <allocproc+0xa8>
    if(p->state == UNUSED)
8010398e:	8b 43 0c             	mov    0xc(%ebx),%eax
80103991:	85 c0                	test   %eax,%eax
80103993:	75 eb                	jne    80103980 <allocproc+0x20>
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
80103995:	a1 04 b0 10 80       	mov    0x8010b004,%eax

  release(&ptable.lock);
8010399a:	83 ec 0c             	sub    $0xc,%esp
  p->state = EMBRYO;
8010399d:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
801039a4:	89 43 10             	mov    %eax,0x10(%ebx)
801039a7:	8d 50 01             	lea    0x1(%eax),%edx
  release(&ptable.lock);
801039aa:	68 80 3d 11 80       	push   $0x80113d80
  p->pid = nextpid++;
801039af:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
  release(&ptable.lock);
801039b5:	e8 16 0e 00 00       	call   801047d0 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801039ba:	e8 41 ee ff ff       	call   80102800 <kalloc>
801039bf:	83 c4 10             	add    $0x10,%esp
801039c2:	89 43 08             	mov    %eax,0x8(%ebx)
801039c5:	85 c0                	test   %eax,%eax
801039c7:	74 58                	je     80103a21 <allocproc+0xc1>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801039c9:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
801039cf:	83 ec 04             	sub    $0x4,%esp
  sp -= sizeof *p->context;
801039d2:	05 9c 0f 00 00       	add    $0xf9c,%eax
  sp -= sizeof *p->tf;
801039d7:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
801039da:	c7 40 14 06 5b 10 80 	movl   $0x80105b06,0x14(%eax)
  p->context = (struct context*)sp;
801039e1:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
801039e4:	6a 14                	push   $0x14
801039e6:	6a 00                	push   $0x0
801039e8:	50                   	push   %eax
801039e9:	e8 32 0e 00 00       	call   80104820 <memset>
  p->context->eip = (uint)forkret;
801039ee:	8b 43 1c             	mov    0x1c(%ebx),%eax

  return p;
801039f1:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801039f4:	c7 40 10 40 3a 10 80 	movl   $0x80103a40,0x10(%eax)
}
801039fb:	89 d8                	mov    %ebx,%eax
801039fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a00:	c9                   	leave  
80103a01:	c3                   	ret    
80103a02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  release(&ptable.lock);
80103a08:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80103a0b:	31 db                	xor    %ebx,%ebx
  release(&ptable.lock);
80103a0d:	68 80 3d 11 80       	push   $0x80113d80
80103a12:	e8 b9 0d 00 00       	call   801047d0 <release>
}
80103a17:	89 d8                	mov    %ebx,%eax
  return 0;
80103a19:	83 c4 10             	add    $0x10,%esp
}
80103a1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a1f:	c9                   	leave  
80103a20:	c3                   	ret    
    p->state = UNUSED;
80103a21:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
80103a28:	31 db                	xor    %ebx,%ebx
}
80103a2a:	89 d8                	mov    %ebx,%eax
80103a2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a2f:	c9                   	leave  
80103a30:	c3                   	ret    
80103a31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103a38:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103a3f:	90                   	nop

80103a40 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80103a40:	f3 0f 1e fb          	endbr32 
80103a44:	55                   	push   %ebp
80103a45:	89 e5                	mov    %esp,%ebp
80103a47:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80103a4a:	68 80 3d 11 80       	push   $0x80113d80
80103a4f:	e8 7c 0d 00 00       	call   801047d0 <release>

  if (first) {
80103a54:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80103a59:	83 c4 10             	add    $0x10,%esp
80103a5c:	85 c0                	test   %eax,%eax
80103a5e:	75 08                	jne    80103a68 <forkret+0x28>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
80103a60:	c9                   	leave  
80103a61:	c3                   	ret    
80103a62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    first = 0;
80103a68:	c7 05 00 b0 10 80 00 	movl   $0x0,0x8010b000
80103a6f:	00 00 00 
    iinit(ROOTDEV);
80103a72:	83 ec 0c             	sub    $0xc,%esp
80103a75:	6a 01                	push   $0x1
80103a77:	e8 a4 dc ff ff       	call   80101720 <iinit>
    initlog(ROOTDEV);
80103a7c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103a83:	e8 d8 f3 ff ff       	call   80102e60 <initlog>
}
80103a88:	83 c4 10             	add    $0x10,%esp
80103a8b:	c9                   	leave  
80103a8c:	c3                   	ret    
80103a8d:	8d 76 00             	lea    0x0(%esi),%esi

80103a90 <pinit>:
{
80103a90:	f3 0f 1e fb          	endbr32 
80103a94:	55                   	push   %ebp
80103a95:	89 e5                	mov    %esp,%ebp
80103a97:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103a9a:	68 80 7f 10 80       	push   $0x80107f80
80103a9f:	68 80 3d 11 80       	push   $0x80113d80
80103aa4:	e8 e7 0a 00 00       	call   80104590 <initlock>
}
80103aa9:	83 c4 10             	add    $0x10,%esp
80103aac:	c9                   	leave  
80103aad:	c3                   	ret    
80103aae:	66 90                	xchg   %ax,%ax

80103ab0 <mycpu>:
{
80103ab0:	f3 0f 1e fb          	endbr32 
80103ab4:	55                   	push   %ebp
80103ab5:	89 e5                	mov    %esp,%ebp
80103ab7:	56                   	push   %esi
80103ab8:	53                   	push   %ebx
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103ab9:	9c                   	pushf  
80103aba:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103abb:	f6 c4 02             	test   $0x2,%ah
80103abe:	75 4a                	jne    80103b0a <mycpu+0x5a>
  apicid = lapicid();
80103ac0:	e8 ab ef ff ff       	call   80102a70 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103ac5:	8b 35 60 3d 11 80    	mov    0x80113d60,%esi
  apicid = lapicid();
80103acb:	89 c3                	mov    %eax,%ebx
  for (i = 0; i < ncpu; ++i) {
80103acd:	85 f6                	test   %esi,%esi
80103acf:	7e 2c                	jle    80103afd <mycpu+0x4d>
80103ad1:	31 d2                	xor    %edx,%edx
80103ad3:	eb 0a                	jmp    80103adf <mycpu+0x2f>
80103ad5:	8d 76 00             	lea    0x0(%esi),%esi
80103ad8:	83 c2 01             	add    $0x1,%edx
80103adb:	39 f2                	cmp    %esi,%edx
80103add:	74 1e                	je     80103afd <mycpu+0x4d>
    if (cpus[i].apicid == apicid)
80103adf:	69 ca bc 00 00 00    	imul   $0xbc,%edx,%ecx
80103ae5:	0f b6 81 80 37 11 80 	movzbl -0x7feec880(%ecx),%eax
80103aec:	39 d8                	cmp    %ebx,%eax
80103aee:	75 e8                	jne    80103ad8 <mycpu+0x28>
}
80103af0:	8d 65 f8             	lea    -0x8(%ebp),%esp
      return &cpus[i];
80103af3:	8d 81 80 37 11 80    	lea    -0x7feec880(%ecx),%eax
}
80103af9:	5b                   	pop    %ebx
80103afa:	5e                   	pop    %esi
80103afb:	5d                   	pop    %ebp
80103afc:	c3                   	ret    
  panic("unknown apicid\n");
80103afd:	83 ec 0c             	sub    $0xc,%esp
80103b00:	68 87 7f 10 80       	push   $0x80107f87
80103b05:	e8 76 c9 ff ff       	call   80100480 <panic>
    panic("mycpu called with interrupts enabled\n");
80103b0a:	83 ec 0c             	sub    $0xc,%esp
80103b0d:	68 64 80 10 80       	push   $0x80108064
80103b12:	e8 69 c9 ff ff       	call   80100480 <panic>
80103b17:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103b1e:	66 90                	xchg   %ax,%ax

80103b20 <cpuid>:
cpuid() {
80103b20:	f3 0f 1e fb          	endbr32 
80103b24:	55                   	push   %ebp
80103b25:	89 e5                	mov    %esp,%ebp
80103b27:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103b2a:	e8 81 ff ff ff       	call   80103ab0 <mycpu>
}
80103b2f:	c9                   	leave  
  return mycpu()-cpus;
80103b30:	2d 80 37 11 80       	sub    $0x80113780,%eax
80103b35:	c1 f8 02             	sar    $0x2,%eax
80103b38:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103b3e:	c3                   	ret    
80103b3f:	90                   	nop

80103b40 <myproc>:
myproc(void) {
80103b40:	f3 0f 1e fb          	endbr32 
80103b44:	55                   	push   %ebp
80103b45:	89 e5                	mov    %esp,%ebp
80103b47:	53                   	push   %ebx
80103b48:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103b4b:	e8 00 0b 00 00       	call   80104650 <pushcli>
  c = mycpu();
80103b50:	e8 5b ff ff ff       	call   80103ab0 <mycpu>
  p = c->proc;
80103b55:	8b 98 b8 00 00 00    	mov    0xb8(%eax),%ebx
  popcli();
80103b5b:	e8 10 0c 00 00       	call   80104770 <popcli>
}
80103b60:	83 c4 04             	add    $0x4,%esp
80103b63:	89 d8                	mov    %ebx,%eax
80103b65:	5b                   	pop    %ebx
80103b66:	5d                   	pop    %ebp
80103b67:	c3                   	ret    
80103b68:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103b6f:	90                   	nop

80103b70 <userinit>:
{
80103b70:	f3 0f 1e fb          	endbr32 
80103b74:	55                   	push   %ebp
80103b75:	89 e5                	mov    %esp,%ebp
80103b77:	53                   	push   %ebx
80103b78:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103b7b:	e8 e0 fd ff ff       	call   80103960 <allocproc>
80103b80:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103b82:	a3 b8 b5 10 80       	mov    %eax,0x8010b5b8
  if((p->pgdir = setupkvm()) == 0)
80103b87:	e8 a4 39 00 00       	call   80107530 <setupkvm>
80103b8c:	89 43 04             	mov    %eax,0x4(%ebx)
80103b8f:	85 c0                	test   %eax,%eax
80103b91:	0f 84 bd 00 00 00    	je     80103c54 <userinit+0xe4>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103b97:	83 ec 04             	sub    $0x4,%esp
80103b9a:	68 2c 00 00 00       	push   $0x2c
80103b9f:	68 60 b4 10 80       	push   $0x8010b460
80103ba4:	50                   	push   %eax
80103ba5:	e8 76 36 00 00       	call   80107220 <inituvm>
  memset(p->tf, 0, sizeof(*p->tf));
80103baa:	83 c4 0c             	add    $0xc,%esp
  p->sz = PGSIZE;
80103bad:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103bb3:	6a 4c                	push   $0x4c
80103bb5:	6a 00                	push   $0x0
80103bb7:	ff 73 18             	pushl  0x18(%ebx)
80103bba:	e8 61 0c 00 00       	call   80104820 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bbf:	8b 43 18             	mov    0x18(%ebx),%eax
80103bc2:	ba 1b 00 00 00       	mov    $0x1b,%edx
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103bc7:	83 c4 0c             	add    $0xc,%esp
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103bca:	b9 23 00 00 00       	mov    $0x23,%ecx
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bcf:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103bd3:	8b 43 18             	mov    0x18(%ebx),%eax
80103bd6:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103bda:	8b 43 18             	mov    0x18(%ebx),%eax
80103bdd:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103be1:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103be5:	8b 43 18             	mov    0x18(%ebx),%eax
80103be8:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103bec:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103bf0:	8b 43 18             	mov    0x18(%ebx),%eax
80103bf3:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103bfa:	8b 43 18             	mov    0x18(%ebx),%eax
80103bfd:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c04:	8b 43 18             	mov    0x18(%ebx),%eax
80103c07:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c0e:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103c11:	6a 10                	push   $0x10
80103c13:	68 b0 7f 10 80       	push   $0x80107fb0
80103c18:	50                   	push   %eax
80103c19:	e8 c2 0d 00 00       	call   801049e0 <safestrcpy>
  p->cwd = namei("/");
80103c1e:	c7 04 24 b9 7f 10 80 	movl   $0x80107fb9,(%esp)
80103c25:	e8 e6 e5 ff ff       	call   80102210 <namei>
80103c2a:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103c2d:	c7 04 24 80 3d 11 80 	movl   $0x80113d80,(%esp)
80103c34:	e8 67 0a 00 00       	call   801046a0 <acquire>
  p->state = RUNNABLE;
80103c39:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103c40:	c7 04 24 80 3d 11 80 	movl   $0x80113d80,(%esp)
80103c47:	e8 84 0b 00 00       	call   801047d0 <release>
}
80103c4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c4f:	83 c4 10             	add    $0x10,%esp
80103c52:	c9                   	leave  
80103c53:	c3                   	ret    
    panic("userinit: out of memory?");
80103c54:	83 ec 0c             	sub    $0xc,%esp
80103c57:	68 97 7f 10 80       	push   $0x80107f97
80103c5c:	e8 1f c8 ff ff       	call   80100480 <panic>
80103c61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103c68:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103c6f:	90                   	nop

80103c70 <growproc>:
{
80103c70:	f3 0f 1e fb          	endbr32 
80103c74:	55                   	push   %ebp
80103c75:	89 e5                	mov    %esp,%ebp
80103c77:	56                   	push   %esi
80103c78:	53                   	push   %ebx
80103c79:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103c7c:	e8 cf 09 00 00       	call   80104650 <pushcli>
  c = mycpu();
80103c81:	e8 2a fe ff ff       	call   80103ab0 <mycpu>
  p = c->proc;
80103c86:	8b b0 b8 00 00 00    	mov    0xb8(%eax),%esi
  popcli();
80103c8c:	e8 df 0a 00 00       	call   80104770 <popcli>
  if (n < 0 || n > KERNBASE || curproc->sz + n > KERNBASE)
80103c91:	85 db                	test   %ebx,%ebx
80103c93:	78 1b                	js     80103cb0 <growproc+0x40>
80103c95:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80103c9b:	77 13                	ja     80103cb0 <growproc+0x40>
80103c9d:	03 1e                	add    (%esi),%ebx
80103c9f:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80103ca5:	77 09                	ja     80103cb0 <growproc+0x40>
  curproc->sz += n;
80103ca7:	89 1e                	mov    %ebx,(%esi)
  return 0;
80103ca9:	31 c0                	xor    %eax,%eax
}
80103cab:	5b                   	pop    %ebx
80103cac:	5e                   	pop    %esi
80103cad:	5d                   	pop    %ebp
80103cae:	c3                   	ret    
80103caf:	90                   	nop
	  return -1;
80103cb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cb5:	eb f4                	jmp    80103cab <growproc+0x3b>
80103cb7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103cbe:	66 90                	xchg   %ax,%ax

80103cc0 <fork>:
{
80103cc0:	f3 0f 1e fb          	endbr32 
80103cc4:	55                   	push   %ebp
80103cc5:	89 e5                	mov    %esp,%ebp
80103cc7:	57                   	push   %edi
80103cc8:	56                   	push   %esi
80103cc9:	53                   	push   %ebx
80103cca:	83 ec 1c             	sub    $0x1c,%esp
  pushcli();
80103ccd:	e8 7e 09 00 00       	call   80104650 <pushcli>
  c = mycpu();
80103cd2:	e8 d9 fd ff ff       	call   80103ab0 <mycpu>
  p = c->proc;
80103cd7:	8b 98 b8 00 00 00    	mov    0xb8(%eax),%ebx
  popcli();
80103cdd:	e8 8e 0a 00 00       	call   80104770 <popcli>
  if((np = allocproc()) == 0){
80103ce2:	e8 79 fc ff ff       	call   80103960 <allocproc>
80103ce7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103cea:	85 c0                	test   %eax,%eax
80103cec:	0f 84 bb 00 00 00    	je     80103dad <fork+0xed>
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103cf2:	83 ec 08             	sub    $0x8,%esp
80103cf5:	ff 33                	pushl  (%ebx)
80103cf7:	89 c7                	mov    %eax,%edi
80103cf9:	ff 73 04             	pushl  0x4(%ebx)
80103cfc:	e8 7f 3a 00 00       	call   80107780 <copyuvm>
80103d01:	83 c4 10             	add    $0x10,%esp
80103d04:	89 47 04             	mov    %eax,0x4(%edi)
80103d07:	85 c0                	test   %eax,%eax
80103d09:	0f 84 a5 00 00 00    	je     80103db4 <fork+0xf4>
  np->sz = curproc->sz;
80103d0f:	8b 03                	mov    (%ebx),%eax
80103d11:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103d14:	89 01                	mov    %eax,(%ecx)
  *np->tf = *curproc->tf;
80103d16:	8b 79 18             	mov    0x18(%ecx),%edi
  np->parent = curproc;
80103d19:	89 c8                	mov    %ecx,%eax
80103d1b:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
80103d1e:	b9 13 00 00 00       	mov    $0x13,%ecx
80103d23:	8b 73 18             	mov    0x18(%ebx),%esi
80103d26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  for(i = 0; i < NOFILE; i++)
80103d28:	31 f6                	xor    %esi,%esi
  np->tf->eax = 0;
80103d2a:	8b 40 18             	mov    0x18(%eax),%eax
80103d2d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[i])
80103d38:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103d3c:	85 c0                	test   %eax,%eax
80103d3e:	74 13                	je     80103d53 <fork+0x93>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103d40:	83 ec 0c             	sub    $0xc,%esp
80103d43:	50                   	push   %eax
80103d44:	e8 17 d2 ff ff       	call   80100f60 <filedup>
80103d49:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103d4c:	83 c4 10             	add    $0x10,%esp
80103d4f:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
  for(i = 0; i < NOFILE; i++)
80103d53:	83 c6 01             	add    $0x1,%esi
80103d56:	83 fe 10             	cmp    $0x10,%esi
80103d59:	75 dd                	jne    80103d38 <fork+0x78>
  np->cwd = idup(curproc->cwd);
80103d5b:	83 ec 0c             	sub    $0xc,%esp
80103d5e:	ff 73 68             	pushl  0x68(%ebx)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103d61:	83 c3 6c             	add    $0x6c,%ebx
  np->cwd = idup(curproc->cwd);
80103d64:	e8 a7 db ff ff       	call   80101910 <idup>
80103d69:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103d6c:	83 c4 0c             	add    $0xc,%esp
  np->cwd = idup(curproc->cwd);
80103d6f:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103d72:	8d 47 6c             	lea    0x6c(%edi),%eax
80103d75:	6a 10                	push   $0x10
80103d77:	53                   	push   %ebx
80103d78:	50                   	push   %eax
80103d79:	e8 62 0c 00 00       	call   801049e0 <safestrcpy>
  pid = np->pid;
80103d7e:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
80103d81:	c7 04 24 80 3d 11 80 	movl   $0x80113d80,(%esp)
80103d88:	e8 13 09 00 00       	call   801046a0 <acquire>
  np->state = RUNNABLE;
80103d8d:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
80103d94:	c7 04 24 80 3d 11 80 	movl   $0x80113d80,(%esp)
80103d9b:	e8 30 0a 00 00       	call   801047d0 <release>
  return pid;
80103da0:	83 c4 10             	add    $0x10,%esp
}
80103da3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103da6:	89 d8                	mov    %ebx,%eax
80103da8:	5b                   	pop    %ebx
80103da9:	5e                   	pop    %esi
80103daa:	5f                   	pop    %edi
80103dab:	5d                   	pop    %ebp
80103dac:	c3                   	ret    
    return -1;
80103dad:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103db2:	eb ef                	jmp    80103da3 <fork+0xe3>
    kfree(np->kstack);
80103db4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103db7:	83 ec 0c             	sub    $0xc,%esp
80103dba:	ff 73 08             	pushl  0x8(%ebx)
80103dbd:	e8 7e e8 ff ff       	call   80102640 <kfree>
    np->kstack = 0;
80103dc2:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    return -1;
80103dc9:	83 c4 10             	add    $0x10,%esp
    np->state = UNUSED;
80103dcc:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103dd3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103dd8:	eb c9                	jmp    80103da3 <fork+0xe3>
80103dda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103de0 <scheduler>:
{
80103de0:	f3 0f 1e fb          	endbr32 
80103de4:	55                   	push   %ebp
80103de5:	89 e5                	mov    %esp,%ebp
80103de7:	57                   	push   %edi
80103de8:	56                   	push   %esi
80103de9:	53                   	push   %ebx
80103dea:	83 ec 0c             	sub    $0xc,%esp
  struct cpu *c = mycpu();
80103ded:	e8 be fc ff ff       	call   80103ab0 <mycpu>
  c->proc = 0;
80103df2:	c7 80 b8 00 00 00 00 	movl   $0x0,0xb8(%eax)
80103df9:	00 00 00 
  struct cpu *c = mycpu();
80103dfc:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103dfe:	8d 78 04             	lea    0x4(%eax),%edi
80103e01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  asm volatile("sti");
80103e08:	fb                   	sti    
    acquire(&ptable.lock);
80103e09:	83 ec 0c             	sub    $0xc,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103e0c:	bb b4 3d 11 80       	mov    $0x80113db4,%ebx
    acquire(&ptable.lock);
80103e11:	68 80 3d 11 80       	push   $0x80113d80
80103e16:	e8 85 08 00 00       	call   801046a0 <acquire>
80103e1b:	83 c4 10             	add    $0x10,%esp
80103e1e:	66 90                	xchg   %ax,%ax
      if(p->state != RUNNABLE)
80103e20:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103e24:	75 33                	jne    80103e59 <scheduler+0x79>
      switchuvm(p);
80103e26:	83 ec 0c             	sub    $0xc,%esp
      c->proc = p;
80103e29:	89 9e b8 00 00 00    	mov    %ebx,0xb8(%esi)
      switchuvm(p);
80103e2f:	53                   	push   %ebx
80103e30:	e8 db 32 00 00       	call   80107110 <switchuvm>
      swtch(&(c->scheduler), p->context);
80103e35:	58                   	pop    %eax
80103e36:	5a                   	pop    %edx
80103e37:	ff 73 1c             	pushl  0x1c(%ebx)
80103e3a:	57                   	push   %edi
      p->state = RUNNING;
80103e3b:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
80103e42:	e8 fc 0b 00 00       	call   80104a43 <swtch>
      switchkvm();
80103e47:	e8 a4 32 00 00       	call   801070f0 <switchkvm>
      c->proc = 0;
80103e4c:	83 c4 10             	add    $0x10,%esp
80103e4f:	c7 86 b8 00 00 00 00 	movl   $0x0,0xb8(%esi)
80103e56:	00 00 00 
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103e59:	81 c3 00 01 00 00    	add    $0x100,%ebx
80103e5f:	81 fb b4 7d 11 80    	cmp    $0x80117db4,%ebx
80103e65:	75 b9                	jne    80103e20 <scheduler+0x40>
    release(&ptable.lock);
80103e67:	83 ec 0c             	sub    $0xc,%esp
80103e6a:	68 80 3d 11 80       	push   $0x80113d80
80103e6f:	e8 5c 09 00 00       	call   801047d0 <release>
    sti();
80103e74:	83 c4 10             	add    $0x10,%esp
80103e77:	eb 8f                	jmp    80103e08 <scheduler+0x28>
80103e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103e80 <sched>:
{
80103e80:	f3 0f 1e fb          	endbr32 
80103e84:	55                   	push   %ebp
80103e85:	89 e5                	mov    %esp,%ebp
80103e87:	56                   	push   %esi
80103e88:	53                   	push   %ebx
  pushcli();
80103e89:	e8 c2 07 00 00       	call   80104650 <pushcli>
  c = mycpu();
80103e8e:	e8 1d fc ff ff       	call   80103ab0 <mycpu>
  p = c->proc;
80103e93:	8b 98 b8 00 00 00    	mov    0xb8(%eax),%ebx
  popcli();
80103e99:	e8 d2 08 00 00       	call   80104770 <popcli>
  if(!holding(&ptable.lock))
80103e9e:	83 ec 0c             	sub    $0xc,%esp
80103ea1:	68 80 3d 11 80       	push   $0x80113d80
80103ea6:	e8 65 07 00 00       	call   80104610 <holding>
80103eab:	83 c4 10             	add    $0x10,%esp
80103eae:	85 c0                	test   %eax,%eax
80103eb0:	74 4f                	je     80103f01 <sched+0x81>
  if(mycpu()->ncli != 1)
80103eb2:	e8 f9 fb ff ff       	call   80103ab0 <mycpu>
80103eb7:	83 b8 ac 00 00 00 01 	cmpl   $0x1,0xac(%eax)
80103ebe:	75 68                	jne    80103f28 <sched+0xa8>
  if(p->state == RUNNING)
80103ec0:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103ec4:	74 55                	je     80103f1b <sched+0x9b>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103ec6:	9c                   	pushf  
80103ec7:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103ec8:	f6 c4 02             	test   $0x2,%ah
80103ecb:	75 41                	jne    80103f0e <sched+0x8e>
  intena = mycpu()->intena;
80103ecd:	e8 de fb ff ff       	call   80103ab0 <mycpu>
  swtch(&p->context, mycpu()->scheduler);
80103ed2:	83 c3 1c             	add    $0x1c,%ebx
  intena = mycpu()->intena;
80103ed5:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103edb:	e8 d0 fb ff ff       	call   80103ab0 <mycpu>
80103ee0:	83 ec 08             	sub    $0x8,%esp
80103ee3:	ff 70 04             	pushl  0x4(%eax)
80103ee6:	53                   	push   %ebx
80103ee7:	e8 57 0b 00 00       	call   80104a43 <swtch>
  mycpu()->intena = intena;
80103eec:	e8 bf fb ff ff       	call   80103ab0 <mycpu>
}
80103ef1:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80103ef4:	89 b0 b0 00 00 00    	mov    %esi,0xb0(%eax)
}
80103efa:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103efd:	5b                   	pop    %ebx
80103efe:	5e                   	pop    %esi
80103eff:	5d                   	pop    %ebp
80103f00:	c3                   	ret    
    panic("sched ptable.lock");
80103f01:	83 ec 0c             	sub    $0xc,%esp
80103f04:	68 bb 7f 10 80       	push   $0x80107fbb
80103f09:	e8 72 c5 ff ff       	call   80100480 <panic>
    panic("sched interruptible");
80103f0e:	83 ec 0c             	sub    $0xc,%esp
80103f11:	68 e7 7f 10 80       	push   $0x80107fe7
80103f16:	e8 65 c5 ff ff       	call   80100480 <panic>
    panic("sched running");
80103f1b:	83 ec 0c             	sub    $0xc,%esp
80103f1e:	68 d9 7f 10 80       	push   $0x80107fd9
80103f23:	e8 58 c5 ff ff       	call   80100480 <panic>
    panic("sched locks");
80103f28:	83 ec 0c             	sub    $0xc,%esp
80103f2b:	68 cd 7f 10 80       	push   $0x80107fcd
80103f30:	e8 4b c5 ff ff       	call   80100480 <panic>
80103f35:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103f3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103f40 <exit>:
{
80103f40:	f3 0f 1e fb          	endbr32 
80103f44:	55                   	push   %ebp
80103f45:	89 e5                	mov    %esp,%ebp
80103f47:	57                   	push   %edi
80103f48:	56                   	push   %esi
80103f49:	53                   	push   %ebx
80103f4a:	83 ec 0c             	sub    $0xc,%esp
  pushcli();
80103f4d:	e8 fe 06 00 00       	call   80104650 <pushcli>
  c = mycpu();
80103f52:	e8 59 fb ff ff       	call   80103ab0 <mycpu>
  p = c->proc;
80103f57:	8b b0 b8 00 00 00    	mov    0xb8(%eax),%esi
  popcli();
80103f5d:	e8 0e 08 00 00       	call   80104770 <popcli>
  if(curproc == initproc)
80103f62:	8d 5e 28             	lea    0x28(%esi),%ebx
80103f65:	8d 7e 68             	lea    0x68(%esi),%edi
80103f68:	39 35 b8 b5 10 80    	cmp    %esi,0x8010b5b8
80103f6e:	0f 84 fd 00 00 00    	je     80104071 <exit+0x131>
80103f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[fd]){
80103f78:	8b 03                	mov    (%ebx),%eax
80103f7a:	85 c0                	test   %eax,%eax
80103f7c:	74 12                	je     80103f90 <exit+0x50>
      fileclose(curproc->ofile[fd]);
80103f7e:	83 ec 0c             	sub    $0xc,%esp
80103f81:	50                   	push   %eax
80103f82:	e8 29 d0 ff ff       	call   80100fb0 <fileclose>
      curproc->ofile[fd] = 0;
80103f87:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
80103f8d:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
80103f90:	83 c3 04             	add    $0x4,%ebx
80103f93:	39 df                	cmp    %ebx,%edi
80103f95:	75 e1                	jne    80103f78 <exit+0x38>
  begin_op();
80103f97:	e8 64 ef ff ff       	call   80102f00 <begin_op>
  iput(curproc->cwd);
80103f9c:	83 ec 0c             	sub    $0xc,%esp
80103f9f:	ff 76 68             	pushl  0x68(%esi)
80103fa2:	e8 c9 da ff ff       	call   80101a70 <iput>
  end_op();
80103fa7:	e8 c4 ef ff ff       	call   80102f70 <end_op>
  curproc->cwd = 0;
80103fac:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
80103fb3:	c7 04 24 80 3d 11 80 	movl   $0x80113d80,(%esp)
80103fba:	e8 e1 06 00 00       	call   801046a0 <acquire>
  wakeup1(curproc->parent);
80103fbf:	8b 56 14             	mov    0x14(%esi),%edx
80103fc2:	83 c4 10             	add    $0x10,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103fc5:	b8 b4 3d 11 80       	mov    $0x80113db4,%eax
80103fca:	eb 10                	jmp    80103fdc <exit+0x9c>
80103fcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103fd0:	05 00 01 00 00       	add    $0x100,%eax
80103fd5:	3d b4 7d 11 80       	cmp    $0x80117db4,%eax
80103fda:	74 1e                	je     80103ffa <exit+0xba>
    if(p->state == SLEEPING && p->chan == chan)
80103fdc:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103fe0:	75 ee                	jne    80103fd0 <exit+0x90>
80103fe2:	3b 50 20             	cmp    0x20(%eax),%edx
80103fe5:	75 e9                	jne    80103fd0 <exit+0x90>
      p->state = RUNNABLE;
80103fe7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103fee:	05 00 01 00 00       	add    $0x100,%eax
80103ff3:	3d b4 7d 11 80       	cmp    $0x80117db4,%eax
80103ff8:	75 e2                	jne    80103fdc <exit+0x9c>
      p->parent = initproc;
80103ffa:	8b 0d b8 b5 10 80    	mov    0x8010b5b8,%ecx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104000:	ba b4 3d 11 80       	mov    $0x80113db4,%edx
80104005:	eb 17                	jmp    8010401e <exit+0xde>
80104007:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010400e:	66 90                	xchg   %ax,%ax
80104010:	81 c2 00 01 00 00    	add    $0x100,%edx
80104016:	81 fa b4 7d 11 80    	cmp    $0x80117db4,%edx
8010401c:	74 3a                	je     80104058 <exit+0x118>
    if(p->parent == curproc){
8010401e:	39 72 14             	cmp    %esi,0x14(%edx)
80104021:	75 ed                	jne    80104010 <exit+0xd0>
      if(p->state == ZOMBIE)
80104023:	83 7a 0c 05          	cmpl   $0x5,0xc(%edx)
      p->parent = initproc;
80104027:	89 4a 14             	mov    %ecx,0x14(%edx)
      if(p->state == ZOMBIE)
8010402a:	75 e4                	jne    80104010 <exit+0xd0>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010402c:	b8 b4 3d 11 80       	mov    $0x80113db4,%eax
80104031:	eb 11                	jmp    80104044 <exit+0x104>
80104033:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104037:	90                   	nop
80104038:	05 00 01 00 00       	add    $0x100,%eax
8010403d:	3d b4 7d 11 80       	cmp    $0x80117db4,%eax
80104042:	74 cc                	je     80104010 <exit+0xd0>
    if(p->state == SLEEPING && p->chan == chan)
80104044:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80104048:	75 ee                	jne    80104038 <exit+0xf8>
8010404a:	3b 48 20             	cmp    0x20(%eax),%ecx
8010404d:	75 e9                	jne    80104038 <exit+0xf8>
      p->state = RUNNABLE;
8010404f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80104056:	eb e0                	jmp    80104038 <exit+0xf8>
  curproc->state = ZOMBIE;
80104058:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
8010405f:	e8 1c fe ff ff       	call   80103e80 <sched>
  panic("zombie exit");
80104064:	83 ec 0c             	sub    $0xc,%esp
80104067:	68 08 80 10 80       	push   $0x80108008
8010406c:	e8 0f c4 ff ff       	call   80100480 <panic>
    panic("init exiting");
80104071:	83 ec 0c             	sub    $0xc,%esp
80104074:	68 fb 7f 10 80       	push   $0x80107ffb
80104079:	e8 02 c4 ff ff       	call   80100480 <panic>
8010407e:	66 90                	xchg   %ax,%ax

80104080 <yield>:
{
80104080:	f3 0f 1e fb          	endbr32 
80104084:	55                   	push   %ebp
80104085:	89 e5                	mov    %esp,%ebp
80104087:	53                   	push   %ebx
80104088:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010408b:	68 80 3d 11 80       	push   $0x80113d80
80104090:	e8 0b 06 00 00       	call   801046a0 <acquire>
  pushcli();
80104095:	e8 b6 05 00 00       	call   80104650 <pushcli>
  c = mycpu();
8010409a:	e8 11 fa ff ff       	call   80103ab0 <mycpu>
  p = c->proc;
8010409f:	8b 98 b8 00 00 00    	mov    0xb8(%eax),%ebx
  popcli();
801040a5:	e8 c6 06 00 00       	call   80104770 <popcli>
  myproc()->state = RUNNABLE;
801040aa:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  sched();
801040b1:	e8 ca fd ff ff       	call   80103e80 <sched>
  release(&ptable.lock);
801040b6:	c7 04 24 80 3d 11 80 	movl   $0x80113d80,(%esp)
801040bd:	e8 0e 07 00 00       	call   801047d0 <release>
}
801040c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801040c5:	83 c4 10             	add    $0x10,%esp
801040c8:	c9                   	leave  
801040c9:	c3                   	ret    
801040ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801040d0 <sleep>:
{
801040d0:	f3 0f 1e fb          	endbr32 
801040d4:	55                   	push   %ebp
801040d5:	89 e5                	mov    %esp,%ebp
801040d7:	57                   	push   %edi
801040d8:	56                   	push   %esi
801040d9:	53                   	push   %ebx
801040da:	83 ec 0c             	sub    $0xc,%esp
801040dd:	8b 7d 08             	mov    0x8(%ebp),%edi
801040e0:	8b 75 0c             	mov    0xc(%ebp),%esi
  pushcli();
801040e3:	e8 68 05 00 00       	call   80104650 <pushcli>
  c = mycpu();
801040e8:	e8 c3 f9 ff ff       	call   80103ab0 <mycpu>
  p = c->proc;
801040ed:	8b 98 b8 00 00 00    	mov    0xb8(%eax),%ebx
  popcli();
801040f3:	e8 78 06 00 00       	call   80104770 <popcli>
  if(p == 0)
801040f8:	85 db                	test   %ebx,%ebx
801040fa:	0f 84 83 00 00 00    	je     80104183 <sleep+0xb3>
  if(lk == 0)
80104100:	85 f6                	test   %esi,%esi
80104102:	74 72                	je     80104176 <sleep+0xa6>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104104:	81 fe 80 3d 11 80    	cmp    $0x80113d80,%esi
8010410a:	74 4c                	je     80104158 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010410c:	83 ec 0c             	sub    $0xc,%esp
8010410f:	68 80 3d 11 80       	push   $0x80113d80
80104114:	e8 87 05 00 00       	call   801046a0 <acquire>
    release(lk);
80104119:	89 34 24             	mov    %esi,(%esp)
8010411c:	e8 af 06 00 00       	call   801047d0 <release>
  p->chan = chan;
80104121:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
80104124:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
8010412b:	e8 50 fd ff ff       	call   80103e80 <sched>
  p->chan = 0;
80104130:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
    release(&ptable.lock);
80104137:	c7 04 24 80 3d 11 80 	movl   $0x80113d80,(%esp)
8010413e:	e8 8d 06 00 00       	call   801047d0 <release>
    acquire(lk);
80104143:	89 75 08             	mov    %esi,0x8(%ebp)
80104146:	83 c4 10             	add    $0x10,%esp
}
80104149:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010414c:	5b                   	pop    %ebx
8010414d:	5e                   	pop    %esi
8010414e:	5f                   	pop    %edi
8010414f:	5d                   	pop    %ebp
    acquire(lk);
80104150:	e9 4b 05 00 00       	jmp    801046a0 <acquire>
80104155:	8d 76 00             	lea    0x0(%esi),%esi
  p->chan = chan;
80104158:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
8010415b:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80104162:	e8 19 fd ff ff       	call   80103e80 <sched>
  p->chan = 0;
80104167:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
}
8010416e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104171:	5b                   	pop    %ebx
80104172:	5e                   	pop    %esi
80104173:	5f                   	pop    %edi
80104174:	5d                   	pop    %ebp
80104175:	c3                   	ret    
    panic("sleep without lk");
80104176:	83 ec 0c             	sub    $0xc,%esp
80104179:	68 1a 80 10 80       	push   $0x8010801a
8010417e:	e8 fd c2 ff ff       	call   80100480 <panic>
    panic("sleep");
80104183:	83 ec 0c             	sub    $0xc,%esp
80104186:	68 14 80 10 80       	push   $0x80108014
8010418b:	e8 f0 c2 ff ff       	call   80100480 <panic>

80104190 <wait>:
{
80104190:	f3 0f 1e fb          	endbr32 
80104194:	55                   	push   %ebp
80104195:	89 e5                	mov    %esp,%ebp
80104197:	57                   	push   %edi
80104198:	56                   	push   %esi
80104199:	53                   	push   %ebx
8010419a:	83 ec 0c             	sub    $0xc,%esp
  pushcli();
8010419d:	e8 ae 04 00 00       	call   80104650 <pushcli>
  c = mycpu();
801041a2:	e8 09 f9 ff ff       	call   80103ab0 <mycpu>
  p = c->proc;
801041a7:	8b b0 b8 00 00 00    	mov    0xb8(%eax),%esi
  popcli();
801041ad:	e8 be 05 00 00       	call   80104770 <popcli>
  acquire(&ptable.lock);
801041b2:	83 ec 0c             	sub    $0xc,%esp
801041b5:	68 80 3d 11 80       	push   $0x80113d80
801041ba:	e8 e1 04 00 00       	call   801046a0 <acquire>
801041bf:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801041c2:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041c4:	bb b4 3d 11 80       	mov    $0x80113db4,%ebx
801041c9:	eb 13                	jmp    801041de <wait+0x4e>
801041cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801041cf:	90                   	nop
801041d0:	81 c3 00 01 00 00    	add    $0x100,%ebx
801041d6:	81 fb b4 7d 11 80    	cmp    $0x80117db4,%ebx
801041dc:	74 1e                	je     801041fc <wait+0x6c>
      if(p->parent != curproc)
801041de:	39 73 14             	cmp    %esi,0x14(%ebx)
801041e1:	75 ed                	jne    801041d0 <wait+0x40>
      if(p->state == ZOMBIE){
801041e3:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801041e7:	74 37                	je     80104220 <wait+0x90>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041e9:	81 c3 00 01 00 00    	add    $0x100,%ebx
      havekids = 1;
801041ef:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041f4:	81 fb b4 7d 11 80    	cmp    $0x80117db4,%ebx
801041fa:	75 e2                	jne    801041de <wait+0x4e>
    if(!havekids || curproc->killed){
801041fc:	85 c0                	test   %eax,%eax
801041fe:	0f 84 7c 00 00 00    	je     80104280 <wait+0xf0>
80104204:	8b 46 24             	mov    0x24(%esi),%eax
80104207:	85 c0                	test   %eax,%eax
80104209:	75 75                	jne    80104280 <wait+0xf0>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010420b:	83 ec 08             	sub    $0x8,%esp
8010420e:	68 80 3d 11 80       	push   $0x80113d80
80104213:	56                   	push   %esi
80104214:	e8 b7 fe ff ff       	call   801040d0 <sleep>
    havekids = 0;
80104219:	83 c4 10             	add    $0x10,%esp
8010421c:	eb a4                	jmp    801041c2 <wait+0x32>
8010421e:	66 90                	xchg   %ax,%ax
        kfree(p->kstack);
80104220:	83 ec 0c             	sub    $0xc,%esp
80104223:	ff 73 08             	pushl  0x8(%ebx)
        pid = p->pid;
80104226:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80104229:	e8 12 e4 ff ff       	call   80102640 <kfree>
        pgdir = p->pgdir;
8010422e:	8b 7b 04             	mov    0x4(%ebx),%edi
        p->name[0] = 0;
80104231:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        release(&ptable.lock);
80104235:	c7 04 24 80 3d 11 80 	movl   $0x80113d80,(%esp)
        p->kstack = 0;
8010423c:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        p->pgdir = 0;
80104243:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
        p->pid = 0;
8010424a:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80104251:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->killed = 0;
80104258:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
8010425f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80104266:	e8 65 05 00 00       	call   801047d0 <release>
        freevm(pgdir);
8010426b:	89 3c 24             	mov    %edi,(%esp)
8010426e:	e8 3d 32 00 00       	call   801074b0 <freevm>
        return pid;
80104273:	83 c4 10             	add    $0x10,%esp
}
80104276:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104279:	89 f0                	mov    %esi,%eax
8010427b:	5b                   	pop    %ebx
8010427c:	5e                   	pop    %esi
8010427d:	5f                   	pop    %edi
8010427e:	5d                   	pop    %ebp
8010427f:	c3                   	ret    
      release(&ptable.lock);
80104280:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80104283:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
80104288:	68 80 3d 11 80       	push   $0x80113d80
8010428d:	e8 3e 05 00 00       	call   801047d0 <release>
      return -1;
80104292:	83 c4 10             	add    $0x10,%esp
80104295:	eb df                	jmp    80104276 <wait+0xe6>
80104297:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010429e:	66 90                	xchg   %ax,%ax

801042a0 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801042a0:	f3 0f 1e fb          	endbr32 
801042a4:	55                   	push   %ebp
801042a5:	89 e5                	mov    %esp,%ebp
801042a7:	53                   	push   %ebx
801042a8:	83 ec 10             	sub    $0x10,%esp
801042ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
801042ae:	68 80 3d 11 80       	push   $0x80113d80
801042b3:	e8 e8 03 00 00       	call   801046a0 <acquire>
801042b8:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801042bb:	b8 b4 3d 11 80       	mov    $0x80113db4,%eax
801042c0:	eb 12                	jmp    801042d4 <wakeup+0x34>
801042c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801042c8:	05 00 01 00 00       	add    $0x100,%eax
801042cd:	3d b4 7d 11 80       	cmp    $0x80117db4,%eax
801042d2:	74 1e                	je     801042f2 <wakeup+0x52>
    if(p->state == SLEEPING && p->chan == chan)
801042d4:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801042d8:	75 ee                	jne    801042c8 <wakeup+0x28>
801042da:	3b 58 20             	cmp    0x20(%eax),%ebx
801042dd:	75 e9                	jne    801042c8 <wakeup+0x28>
      p->state = RUNNABLE;
801042df:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801042e6:	05 00 01 00 00       	add    $0x100,%eax
801042eb:	3d b4 7d 11 80       	cmp    $0x80117db4,%eax
801042f0:	75 e2                	jne    801042d4 <wakeup+0x34>
  wakeup1(chan);
  release(&ptable.lock);
801042f2:	c7 45 08 80 3d 11 80 	movl   $0x80113d80,0x8(%ebp)
}
801042f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042fc:	c9                   	leave  
  release(&ptable.lock);
801042fd:	e9 ce 04 00 00       	jmp    801047d0 <release>
80104302:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104310 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104310:	f3 0f 1e fb          	endbr32 
80104314:	55                   	push   %ebp
80104315:	89 e5                	mov    %esp,%ebp
80104317:	53                   	push   %ebx
80104318:	83 ec 10             	sub    $0x10,%esp
8010431b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
8010431e:	68 80 3d 11 80       	push   $0x80113d80
80104323:	e8 78 03 00 00       	call   801046a0 <acquire>
80104328:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010432b:	b8 b4 3d 11 80       	mov    $0x80113db4,%eax
80104330:	eb 12                	jmp    80104344 <kill+0x34>
80104332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104338:	05 00 01 00 00       	add    $0x100,%eax
8010433d:	3d b4 7d 11 80       	cmp    $0x80117db4,%eax
80104342:	74 3c                	je     80104380 <kill+0x70>
    if(p->pid == pid){
80104344:	8b 50 10             	mov    0x10(%eax),%edx
80104347:	39 da                	cmp    %ebx,%edx
80104349:	75 ed                	jne    80104338 <kill+0x28>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010434b:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
      p->killed = 1;
8010434f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      if(p->state == SLEEPING)
80104356:	75 07                	jne    8010435f <kill+0x4f>
        p->state = RUNNABLE;
80104358:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010435f:	83 ec 0c             	sub    $0xc,%esp
80104362:	68 80 3d 11 80       	push   $0x80113d80
80104367:	e8 64 04 00 00       	call   801047d0 <release>
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
8010436c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return 0;
8010436f:	83 c4 10             	add    $0x10,%esp
80104372:	31 c0                	xor    %eax,%eax
}
80104374:	c9                   	leave  
80104375:	c3                   	ret    
80104376:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010437d:	8d 76 00             	lea    0x0(%esi),%esi
  release(&ptable.lock);
80104380:	83 ec 0c             	sub    $0xc,%esp
80104383:	68 80 3d 11 80       	push   $0x80113d80
80104388:	e8 43 04 00 00       	call   801047d0 <release>
}
8010438d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80104390:	83 c4 10             	add    $0x10,%esp
80104393:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104398:	c9                   	leave  
80104399:	c3                   	ret    
8010439a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801043a0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801043a0:	f3 0f 1e fb          	endbr32 
801043a4:	55                   	push   %ebp
801043a5:	89 e5                	mov    %esp,%ebp
801043a7:	57                   	push   %edi
801043a8:	56                   	push   %esi
801043a9:	8d 75 e8             	lea    -0x18(%ebp),%esi
801043ac:	53                   	push   %ebx
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801043ad:	bb b4 3d 11 80       	mov    $0x80113db4,%ebx
{
801043b2:	83 ec 3c             	sub    $0x3c,%esp
801043b5:	eb 2b                	jmp    801043e2 <procdump+0x42>
801043b7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801043be:	66 90                	xchg   %ax,%ax
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801043c0:	83 ec 0c             	sub    $0xc,%esp
801043c3:	68 94 84 10 80       	push   $0x80108494
801043c8:	e8 d3 c3 ff ff       	call   801007a0 <cprintf>
801043cd:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801043d0:	81 c3 00 01 00 00    	add    $0x100,%ebx
801043d6:	81 fb b4 7d 11 80    	cmp    $0x80117db4,%ebx
801043dc:	0f 84 8e 00 00 00    	je     80104470 <procdump+0xd0>
    if(p->state == UNUSED)
801043e2:	8b 43 0c             	mov    0xc(%ebx),%eax
801043e5:	85 c0                	test   %eax,%eax
801043e7:	74 e7                	je     801043d0 <procdump+0x30>
      state = "???";
801043e9:	ba 2b 80 10 80       	mov    $0x8010802b,%edx
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801043ee:	83 f8 05             	cmp    $0x5,%eax
801043f1:	77 11                	ja     80104404 <procdump+0x64>
801043f3:	8b 14 85 8c 80 10 80 	mov    -0x7fef7f74(,%eax,4),%edx
      state = "???";
801043fa:	b8 2b 80 10 80       	mov    $0x8010802b,%eax
801043ff:	85 d2                	test   %edx,%edx
80104401:	0f 44 d0             	cmove  %eax,%edx
    cprintf("%d %s %s", p->pid, state, p->name);
80104404:	8b 43 10             	mov    0x10(%ebx),%eax
80104407:	8d 4b 6c             	lea    0x6c(%ebx),%ecx
8010440a:	51                   	push   %ecx
8010440b:	52                   	push   %edx
8010440c:	50                   	push   %eax
8010440d:	68 2f 80 10 80       	push   $0x8010802f
80104412:	e8 89 c3 ff ff       	call   801007a0 <cprintf>
    if(p->state == SLEEPING){
80104417:	83 c4 10             	add    $0x10,%esp
8010441a:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
8010441e:	75 a0                	jne    801043c0 <procdump+0x20>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104420:	83 ec 08             	sub    $0x8,%esp
80104423:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104426:	8d 7d c0             	lea    -0x40(%ebp),%edi
80104429:	50                   	push   %eax
8010442a:	8b 43 1c             	mov    0x1c(%ebx),%eax
8010442d:	8b 40 0c             	mov    0xc(%eax),%eax
80104430:	83 c0 08             	add    $0x8,%eax
80104433:	50                   	push   %eax
80104434:	e8 77 01 00 00       	call   801045b0 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104439:	83 c4 10             	add    $0x10,%esp
8010443c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104440:	8b 17                	mov    (%edi),%edx
80104442:	85 d2                	test   %edx,%edx
80104444:	0f 84 76 ff ff ff    	je     801043c0 <procdump+0x20>
        cprintf(" %p", pc[i]);
8010444a:	83 ec 08             	sub    $0x8,%esp
8010444d:	83 c7 04             	add    $0x4,%edi
80104450:	52                   	push   %edx
80104451:	68 81 7a 10 80       	push   $0x80107a81
80104456:	e8 45 c3 ff ff       	call   801007a0 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
8010445b:	83 c4 10             	add    $0x10,%esp
8010445e:	39 fe                	cmp    %edi,%esi
80104460:	75 de                	jne    80104440 <procdump+0xa0>
80104462:	e9 59 ff ff ff       	jmp    801043c0 <procdump+0x20>
80104467:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010446e:	66 90                	xchg   %ax,%ax
  }
}
80104470:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104473:	5b                   	pop    %ebx
80104474:	5e                   	pop    %esi
80104475:	5f                   	pop    %edi
80104476:	5d                   	pop    %ebp
80104477:	c3                   	ret    
80104478:	66 90                	xchg   %ax,%ax
8010447a:	66 90                	xchg   %ax,%ax
8010447c:	66 90                	xchg   %ax,%ax
8010447e:	66 90                	xchg   %ax,%ax

80104480 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104480:	f3 0f 1e fb          	endbr32 
80104484:	55                   	push   %ebp
80104485:	89 e5                	mov    %esp,%ebp
80104487:	53                   	push   %ebx
80104488:	83 ec 0c             	sub    $0xc,%esp
8010448b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
8010448e:	68 a4 80 10 80       	push   $0x801080a4
80104493:	8d 43 04             	lea    0x4(%ebx),%eax
80104496:	50                   	push   %eax
80104497:	e8 f4 00 00 00       	call   80104590 <initlock>
  lk->name = name;
8010449c:	8b 45 0c             	mov    0xc(%ebp),%eax
  lk->locked = 0;
8010449f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
}
801044a5:	83 c4 10             	add    $0x10,%esp
  lk->pid = 0;
801044a8:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  lk->name = name;
801044af:	89 43 38             	mov    %eax,0x38(%ebx)
}
801044b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044b5:	c9                   	leave  
801044b6:	c3                   	ret    
801044b7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801044be:	66 90                	xchg   %ax,%ax

801044c0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801044c0:	f3 0f 1e fb          	endbr32 
801044c4:	55                   	push   %ebp
801044c5:	89 e5                	mov    %esp,%ebp
801044c7:	56                   	push   %esi
801044c8:	53                   	push   %ebx
801044c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801044cc:	8d 73 04             	lea    0x4(%ebx),%esi
801044cf:	83 ec 0c             	sub    $0xc,%esp
801044d2:	56                   	push   %esi
801044d3:	e8 c8 01 00 00       	call   801046a0 <acquire>
  while (lk->locked) {
801044d8:	8b 13                	mov    (%ebx),%edx
801044da:	83 c4 10             	add    $0x10,%esp
801044dd:	85 d2                	test   %edx,%edx
801044df:	74 1a                	je     801044fb <acquiresleep+0x3b>
801044e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    sleep(lk, &lk->lk);
801044e8:	83 ec 08             	sub    $0x8,%esp
801044eb:	56                   	push   %esi
801044ec:	53                   	push   %ebx
801044ed:	e8 de fb ff ff       	call   801040d0 <sleep>
  while (lk->locked) {
801044f2:	8b 03                	mov    (%ebx),%eax
801044f4:	83 c4 10             	add    $0x10,%esp
801044f7:	85 c0                	test   %eax,%eax
801044f9:	75 ed                	jne    801044e8 <acquiresleep+0x28>
  }
  lk->locked = 1;
801044fb:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80104501:	e8 3a f6 ff ff       	call   80103b40 <myproc>
80104506:	8b 40 10             	mov    0x10(%eax),%eax
80104509:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
8010450c:	89 75 08             	mov    %esi,0x8(%ebp)
}
8010450f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104512:	5b                   	pop    %ebx
80104513:	5e                   	pop    %esi
80104514:	5d                   	pop    %ebp
  release(&lk->lk);
80104515:	e9 b6 02 00 00       	jmp    801047d0 <release>
8010451a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104520 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104520:	f3 0f 1e fb          	endbr32 
80104524:	55                   	push   %ebp
80104525:	89 e5                	mov    %esp,%ebp
80104527:	56                   	push   %esi
80104528:	53                   	push   %ebx
80104529:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
8010452c:	8d 73 04             	lea    0x4(%ebx),%esi
8010452f:	83 ec 0c             	sub    $0xc,%esp
80104532:	56                   	push   %esi
80104533:	e8 68 01 00 00       	call   801046a0 <acquire>
  lk->locked = 0;
80104538:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
8010453e:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80104545:	89 1c 24             	mov    %ebx,(%esp)
80104548:	e8 53 fd ff ff       	call   801042a0 <wakeup>
  release(&lk->lk);
8010454d:	89 75 08             	mov    %esi,0x8(%ebp)
80104550:	83 c4 10             	add    $0x10,%esp
}
80104553:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104556:	5b                   	pop    %ebx
80104557:	5e                   	pop    %esi
80104558:	5d                   	pop    %ebp
  release(&lk->lk);
80104559:	e9 72 02 00 00       	jmp    801047d0 <release>
8010455e:	66 90                	xchg   %ax,%ax

80104560 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104560:	f3 0f 1e fb          	endbr32 
80104564:	55                   	push   %ebp
80104565:	89 e5                	mov    %esp,%ebp
80104567:	56                   	push   %esi
80104568:	53                   	push   %ebx
80104569:	8b 75 08             	mov    0x8(%ebp),%esi
  int r;
  
  acquire(&lk->lk);
8010456c:	8d 5e 04             	lea    0x4(%esi),%ebx
8010456f:	83 ec 0c             	sub    $0xc,%esp
80104572:	53                   	push   %ebx
80104573:	e8 28 01 00 00       	call   801046a0 <acquire>
  r = lk->locked;
80104578:	8b 36                	mov    (%esi),%esi
  release(&lk->lk);
8010457a:	89 1c 24             	mov    %ebx,(%esp)
8010457d:	e8 4e 02 00 00       	call   801047d0 <release>
  return r;
}
80104582:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104585:	89 f0                	mov    %esi,%eax
80104587:	5b                   	pop    %ebx
80104588:	5e                   	pop    %esi
80104589:	5d                   	pop    %ebp
8010458a:	c3                   	ret    
8010458b:	66 90                	xchg   %ax,%ax
8010458d:	66 90                	xchg   %ax,%ax
8010458f:	90                   	nop

80104590 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104590:	f3 0f 1e fb          	endbr32 
80104594:	55                   	push   %ebp
80104595:	89 e5                	mov    %esp,%ebp
80104597:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
8010459a:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
8010459d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->name = name;
801045a3:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
801045a6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801045ad:	5d                   	pop    %ebp
801045ae:	c3                   	ret    
801045af:	90                   	nop

801045b0 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801045b0:	f3 0f 1e fb          	endbr32 
801045b4:	55                   	push   %ebp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801045b5:	31 d2                	xor    %edx,%edx
{
801045b7:	89 e5                	mov    %esp,%ebp
801045b9:	53                   	push   %ebx
  ebp = (uint*)v - 2;
801045ba:	8b 45 08             	mov    0x8(%ebp),%eax
{
801045bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  ebp = (uint*)v - 2;
801045c0:	83 e8 08             	sub    $0x8,%eax
  for(i = 0; i < 10; i++){
801045c3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801045c7:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801045c8:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
801045ce:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
801045d4:	77 1a                	ja     801045f0 <getcallerpcs+0x40>
      break;
    pcs[i] = ebp[1];     // saved %eip
801045d6:	8b 58 04             	mov    0x4(%eax),%ebx
801045d9:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
801045dc:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
801045df:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
801045e1:	83 fa 0a             	cmp    $0xa,%edx
801045e4:	75 e2                	jne    801045c8 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
801045e6:	5b                   	pop    %ebx
801045e7:	5d                   	pop    %ebp
801045e8:	c3                   	ret    
801045e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(; i < 10; i++)
801045f0:	8d 04 91             	lea    (%ecx,%edx,4),%eax
801045f3:	8d 51 28             	lea    0x28(%ecx),%edx
801045f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801045fd:	8d 76 00             	lea    0x0(%esi),%esi
    pcs[i] = 0;
80104600:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104606:	83 c0 04             	add    $0x4,%eax
80104609:	39 d0                	cmp    %edx,%eax
8010460b:	75 f3                	jne    80104600 <getcallerpcs+0x50>
}
8010460d:	5b                   	pop    %ebx
8010460e:	5d                   	pop    %ebp
8010460f:	c3                   	ret    

80104610 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104610:	f3 0f 1e fb          	endbr32 
80104614:	55                   	push   %ebp
80104615:	89 e5                	mov    %esp,%ebp
80104617:	53                   	push   %ebx
80104618:	83 ec 04             	sub    $0x4,%esp
8010461b:	8b 55 08             	mov    0x8(%ebp),%edx
  return lock->locked && lock->cpu == mycpu();
8010461e:	8b 02                	mov    (%edx),%eax
80104620:	85 c0                	test   %eax,%eax
80104622:	75 0c                	jne    80104630 <holding+0x20>
}
80104624:	83 c4 04             	add    $0x4,%esp
80104627:	31 c0                	xor    %eax,%eax
80104629:	5b                   	pop    %ebx
8010462a:	5d                   	pop    %ebp
8010462b:	c3                   	ret    
8010462c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  return lock->locked && lock->cpu == mycpu();
80104630:	8b 5a 08             	mov    0x8(%edx),%ebx
80104633:	e8 78 f4 ff ff       	call   80103ab0 <mycpu>
80104638:	39 c3                	cmp    %eax,%ebx
8010463a:	0f 94 c0             	sete   %al
}
8010463d:	83 c4 04             	add    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104640:	0f b6 c0             	movzbl %al,%eax
}
80104643:	5b                   	pop    %ebx
80104644:	5d                   	pop    %ebp
80104645:	c3                   	ret    
80104646:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010464d:	8d 76 00             	lea    0x0(%esi),%esi

80104650 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104650:	f3 0f 1e fb          	endbr32 
80104654:	55                   	push   %ebp
80104655:	89 e5                	mov    %esp,%ebp
80104657:	53                   	push   %ebx
80104658:	83 ec 04             	sub    $0x4,%esp
8010465b:	9c                   	pushf  
8010465c:	5b                   	pop    %ebx
  asm volatile("cli");
8010465d:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
8010465e:	e8 4d f4 ff ff       	call   80103ab0 <mycpu>
80104663:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104669:	85 c0                	test   %eax,%eax
8010466b:	74 13                	je     80104680 <pushcli+0x30>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
8010466d:	e8 3e f4 ff ff       	call   80103ab0 <mycpu>
80104672:	83 80 ac 00 00 00 01 	addl   $0x1,0xac(%eax)
}
80104679:	83 c4 04             	add    $0x4,%esp
8010467c:	5b                   	pop    %ebx
8010467d:	5d                   	pop    %ebp
8010467e:	c3                   	ret    
8010467f:	90                   	nop
    mycpu()->intena = eflags & FL_IF;
80104680:	e8 2b f4 ff ff       	call   80103ab0 <mycpu>
80104685:	81 e3 00 02 00 00    	and    $0x200,%ebx
8010468b:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
80104691:	eb da                	jmp    8010466d <pushcli+0x1d>
80104693:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010469a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801046a0 <acquire>:
{
801046a0:	f3 0f 1e fb          	endbr32 
801046a4:	55                   	push   %ebp
801046a5:	89 e5                	mov    %esp,%ebp
801046a7:	56                   	push   %esi
801046a8:	53                   	push   %ebx
  pushcli(); // disable interrupts to avoid deadlock.
801046a9:	e8 a2 ff ff ff       	call   80104650 <pushcli>
  if(holding(lk))
801046ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  return lock->locked && lock->cpu == mycpu();
801046b1:	8b 03                	mov    (%ebx),%eax
801046b3:	85 c0                	test   %eax,%eax
801046b5:	0f 85 8d 00 00 00    	jne    80104748 <acquire+0xa8>
  asm volatile("lock; xchgl %0, %1" :
801046bb:	ba 01 00 00 00       	mov    $0x1,%edx
801046c0:	eb 09                	jmp    801046cb <acquire+0x2b>
801046c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801046c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
801046cb:	89 d0                	mov    %edx,%eax
801046cd:	f0 87 03             	lock xchg %eax,(%ebx)
  while(xchg(&lk->locked, 1) != 0)
801046d0:	85 c0                	test   %eax,%eax
801046d2:	75 f4                	jne    801046c8 <acquire+0x28>
  __sync_synchronize();
801046d4:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
801046d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
801046dc:	e8 cf f3 ff ff       	call   80103ab0 <mycpu>
  ebp = (uint*)v - 2;
801046e1:	89 ea                	mov    %ebp,%edx
  lk->cpu = mycpu();
801046e3:	89 43 08             	mov    %eax,0x8(%ebx)
  for(i = 0; i < 10; i++){
801046e6:	31 c0                	xor    %eax,%eax
801046e8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801046ef:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801046f0:	8d 8a 00 00 00 80    	lea    -0x80000000(%edx),%ecx
801046f6:	81 f9 fe ff ff 7f    	cmp    $0x7ffffffe,%ecx
801046fc:	77 22                	ja     80104720 <acquire+0x80>
    pcs[i] = ebp[1];     // saved %eip
801046fe:	8b 4a 04             	mov    0x4(%edx),%ecx
80104701:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
  for(i = 0; i < 10; i++){
80104705:	83 c0 01             	add    $0x1,%eax
    ebp = (uint*)ebp[0]; // saved %ebp
80104708:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
8010470a:	83 f8 0a             	cmp    $0xa,%eax
8010470d:	75 e1                	jne    801046f0 <acquire+0x50>
}
8010470f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104712:	5b                   	pop    %ebx
80104713:	5e                   	pop    %esi
80104714:	5d                   	pop    %ebp
80104715:	c3                   	ret    
80104716:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010471d:	8d 76 00             	lea    0x0(%esi),%esi
  for(; i < 10; i++)
80104720:	8d 44 83 0c          	lea    0xc(%ebx,%eax,4),%eax
80104724:	83 c3 34             	add    $0x34,%ebx
80104727:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010472e:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
80104730:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104736:	83 c0 04             	add    $0x4,%eax
80104739:	39 d8                	cmp    %ebx,%eax
8010473b:	75 f3                	jne    80104730 <acquire+0x90>
}
8010473d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104740:	5b                   	pop    %ebx
80104741:	5e                   	pop    %esi
80104742:	5d                   	pop    %ebp
80104743:	c3                   	ret    
80104744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  return lock->locked && lock->cpu == mycpu();
80104748:	8b 73 08             	mov    0x8(%ebx),%esi
8010474b:	e8 60 f3 ff ff       	call   80103ab0 <mycpu>
80104750:	39 c6                	cmp    %eax,%esi
80104752:	0f 85 63 ff ff ff    	jne    801046bb <acquire+0x1b>
    panic("acquire");
80104758:	83 ec 0c             	sub    $0xc,%esp
8010475b:	68 af 80 10 80       	push   $0x801080af
80104760:	e8 1b bd ff ff       	call   80100480 <panic>
80104765:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010476c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104770 <popcli>:

void
popcli(void)
{
80104770:	f3 0f 1e fb          	endbr32 
80104774:	55                   	push   %ebp
80104775:	89 e5                	mov    %esp,%ebp
80104777:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010477a:	9c                   	pushf  
8010477b:	58                   	pop    %eax
  if(readeflags()&FL_IF)
8010477c:	f6 c4 02             	test   $0x2,%ah
8010477f:	75 31                	jne    801047b2 <popcli+0x42>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80104781:	e8 2a f3 ff ff       	call   80103ab0 <mycpu>
80104786:	83 a8 ac 00 00 00 01 	subl   $0x1,0xac(%eax)
8010478d:	78 30                	js     801047bf <popcli+0x4f>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010478f:	e8 1c f3 ff ff       	call   80103ab0 <mycpu>
80104794:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010479a:	85 d2                	test   %edx,%edx
8010479c:	74 02                	je     801047a0 <popcli+0x30>
    sti();
}
8010479e:	c9                   	leave  
8010479f:	c3                   	ret    
  if(mycpu()->ncli == 0 && mycpu()->intena)
801047a0:	e8 0b f3 ff ff       	call   80103ab0 <mycpu>
801047a5:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801047ab:	85 c0                	test   %eax,%eax
801047ad:	74 ef                	je     8010479e <popcli+0x2e>
  asm volatile("sti");
801047af:	fb                   	sti    
}
801047b0:	c9                   	leave  
801047b1:	c3                   	ret    
    panic("popcli - interruptible");
801047b2:	83 ec 0c             	sub    $0xc,%esp
801047b5:	68 b7 80 10 80       	push   $0x801080b7
801047ba:	e8 c1 bc ff ff       	call   80100480 <panic>
    panic("popcli");
801047bf:	83 ec 0c             	sub    $0xc,%esp
801047c2:	68 ce 80 10 80       	push   $0x801080ce
801047c7:	e8 b4 bc ff ff       	call   80100480 <panic>
801047cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801047d0 <release>:
{
801047d0:	f3 0f 1e fb          	endbr32 
801047d4:	55                   	push   %ebp
801047d5:	89 e5                	mov    %esp,%ebp
801047d7:	56                   	push   %esi
801047d8:	53                   	push   %ebx
801047d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  return lock->locked && lock->cpu == mycpu();
801047dc:	8b 03                	mov    (%ebx),%eax
801047de:	85 c0                	test   %eax,%eax
801047e0:	75 0e                	jne    801047f0 <release+0x20>
    panic("release");
801047e2:	83 ec 0c             	sub    $0xc,%esp
801047e5:	68 d5 80 10 80       	push   $0x801080d5
801047ea:	e8 91 bc ff ff       	call   80100480 <panic>
801047ef:	90                   	nop
  return lock->locked && lock->cpu == mycpu();
801047f0:	8b 73 08             	mov    0x8(%ebx),%esi
801047f3:	e8 b8 f2 ff ff       	call   80103ab0 <mycpu>
801047f8:	39 c6                	cmp    %eax,%esi
801047fa:	75 e6                	jne    801047e2 <release+0x12>
  lk->pcs[0] = 0;
801047fc:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80104803:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
8010480a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010480f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}
80104815:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104818:	5b                   	pop    %ebx
80104819:	5e                   	pop    %esi
8010481a:	5d                   	pop    %ebp
  popcli();
8010481b:	e9 50 ff ff ff       	jmp    80104770 <popcli>

80104820 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104820:	f3 0f 1e fb          	endbr32 
80104824:	55                   	push   %ebp
80104825:	89 e5                	mov    %esp,%ebp
80104827:	57                   	push   %edi
80104828:	8b 55 08             	mov    0x8(%ebp),%edx
8010482b:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010482e:	53                   	push   %ebx
8010482f:	8b 45 0c             	mov    0xc(%ebp),%eax
  if ((int)dst%4 == 0 && n%4 == 0){
80104832:	89 d7                	mov    %edx,%edi
80104834:	09 cf                	or     %ecx,%edi
80104836:	83 e7 03             	and    $0x3,%edi
80104839:	75 25                	jne    80104860 <memset+0x40>
    c &= 0xFF;
8010483b:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010483e:	c1 e0 18             	shl    $0x18,%eax
80104841:	89 fb                	mov    %edi,%ebx
80104843:	c1 e9 02             	shr    $0x2,%ecx
80104846:	c1 e3 10             	shl    $0x10,%ebx
80104849:	09 d8                	or     %ebx,%eax
8010484b:	09 f8                	or     %edi,%eax
8010484d:	c1 e7 08             	shl    $0x8,%edi
80104850:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80104852:	89 d7                	mov    %edx,%edi
80104854:	fc                   	cld    
80104855:	f3 ab                	rep stos %eax,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80104857:	5b                   	pop    %ebx
80104858:	89 d0                	mov    %edx,%eax
8010485a:	5f                   	pop    %edi
8010485b:	5d                   	pop    %ebp
8010485c:	c3                   	ret    
8010485d:	8d 76 00             	lea    0x0(%esi),%esi
  asm volatile("cld; rep stosb" :
80104860:	89 d7                	mov    %edx,%edi
80104862:	fc                   	cld    
80104863:	f3 aa                	rep stos %al,%es:(%edi)
80104865:	5b                   	pop    %ebx
80104866:	89 d0                	mov    %edx,%eax
80104868:	5f                   	pop    %edi
80104869:	5d                   	pop    %ebp
8010486a:	c3                   	ret    
8010486b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010486f:	90                   	nop

80104870 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104870:	f3 0f 1e fb          	endbr32 
80104874:	55                   	push   %ebp
80104875:	89 e5                	mov    %esp,%ebp
80104877:	56                   	push   %esi
80104878:	8b 75 10             	mov    0x10(%ebp),%esi
8010487b:	8b 55 08             	mov    0x8(%ebp),%edx
8010487e:	53                   	push   %ebx
8010487f:	8b 45 0c             	mov    0xc(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104882:	85 f6                	test   %esi,%esi
80104884:	74 2a                	je     801048b0 <memcmp+0x40>
80104886:	01 c6                	add    %eax,%esi
80104888:	eb 10                	jmp    8010489a <memcmp+0x2a>
8010488a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80104890:	83 c0 01             	add    $0x1,%eax
80104893:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80104896:	39 f0                	cmp    %esi,%eax
80104898:	74 16                	je     801048b0 <memcmp+0x40>
    if(*s1 != *s2)
8010489a:	0f b6 0a             	movzbl (%edx),%ecx
8010489d:	0f b6 18             	movzbl (%eax),%ebx
801048a0:	38 d9                	cmp    %bl,%cl
801048a2:	74 ec                	je     80104890 <memcmp+0x20>
      return *s1 - *s2;
801048a4:	0f b6 c1             	movzbl %cl,%eax
801048a7:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
801048a9:	5b                   	pop    %ebx
801048aa:	5e                   	pop    %esi
801048ab:	5d                   	pop    %ebp
801048ac:	c3                   	ret    
801048ad:	8d 76 00             	lea    0x0(%esi),%esi
801048b0:	5b                   	pop    %ebx
  return 0;
801048b1:	31 c0                	xor    %eax,%eax
}
801048b3:	5e                   	pop    %esi
801048b4:	5d                   	pop    %ebp
801048b5:	c3                   	ret    
801048b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801048bd:	8d 76 00             	lea    0x0(%esi),%esi

801048c0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801048c0:	f3 0f 1e fb          	endbr32 
801048c4:	55                   	push   %ebp
801048c5:	89 e5                	mov    %esp,%ebp
801048c7:	57                   	push   %edi
801048c8:	8b 55 08             	mov    0x8(%ebp),%edx
801048cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
801048ce:	56                   	push   %esi
801048cf:	8b 75 0c             	mov    0xc(%ebp),%esi
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801048d2:	39 d6                	cmp    %edx,%esi
801048d4:	73 2a                	jae    80104900 <memmove+0x40>
801048d6:	8d 3c 0e             	lea    (%esi,%ecx,1),%edi
801048d9:	39 fa                	cmp    %edi,%edx
801048db:	73 23                	jae    80104900 <memmove+0x40>
801048dd:	8d 41 ff             	lea    -0x1(%ecx),%eax
    s += n;
    d += n;
    while(n-- > 0)
801048e0:	85 c9                	test   %ecx,%ecx
801048e2:	74 13                	je     801048f7 <memmove+0x37>
801048e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      *--d = *--s;
801048e8:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
801048ec:	88 0c 02             	mov    %cl,(%edx,%eax,1)
    while(n-- > 0)
801048ef:	83 e8 01             	sub    $0x1,%eax
801048f2:	83 f8 ff             	cmp    $0xffffffff,%eax
801048f5:	75 f1                	jne    801048e8 <memmove+0x28>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
801048f7:	5e                   	pop    %esi
801048f8:	89 d0                	mov    %edx,%eax
801048fa:	5f                   	pop    %edi
801048fb:	5d                   	pop    %ebp
801048fc:	c3                   	ret    
801048fd:	8d 76 00             	lea    0x0(%esi),%esi
    while(n-- > 0)
80104900:	8d 04 0e             	lea    (%esi,%ecx,1),%eax
80104903:	89 d7                	mov    %edx,%edi
80104905:	85 c9                	test   %ecx,%ecx
80104907:	74 ee                	je     801048f7 <memmove+0x37>
80104909:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      *d++ = *s++;
80104910:	a4                   	movsb  %ds:(%esi),%es:(%edi)
    while(n-- > 0)
80104911:	39 f0                	cmp    %esi,%eax
80104913:	75 fb                	jne    80104910 <memmove+0x50>
}
80104915:	5e                   	pop    %esi
80104916:	89 d0                	mov    %edx,%eax
80104918:	5f                   	pop    %edi
80104919:	5d                   	pop    %ebp
8010491a:	c3                   	ret    
8010491b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010491f:	90                   	nop

80104920 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104920:	f3 0f 1e fb          	endbr32 
  return memmove(dst, src, n);
80104924:	eb 9a                	jmp    801048c0 <memmove>
80104926:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010492d:	8d 76 00             	lea    0x0(%esi),%esi

80104930 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
80104930:	f3 0f 1e fb          	endbr32 
80104934:	55                   	push   %ebp
80104935:	89 e5                	mov    %esp,%ebp
80104937:	56                   	push   %esi
80104938:	8b 75 10             	mov    0x10(%ebp),%esi
8010493b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010493e:	53                   	push   %ebx
8010493f:	8b 45 0c             	mov    0xc(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80104942:	85 f6                	test   %esi,%esi
80104944:	74 32                	je     80104978 <strncmp+0x48>
80104946:	01 c6                	add    %eax,%esi
80104948:	eb 14                	jmp    8010495e <strncmp+0x2e>
8010494a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104950:	38 da                	cmp    %bl,%dl
80104952:	75 14                	jne    80104968 <strncmp+0x38>
    n--, p++, q++;
80104954:	83 c0 01             	add    $0x1,%eax
80104957:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
8010495a:	39 f0                	cmp    %esi,%eax
8010495c:	74 1a                	je     80104978 <strncmp+0x48>
8010495e:	0f b6 11             	movzbl (%ecx),%edx
80104961:	0f b6 18             	movzbl (%eax),%ebx
80104964:	84 d2                	test   %dl,%dl
80104966:	75 e8                	jne    80104950 <strncmp+0x20>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
80104968:	0f b6 c2             	movzbl %dl,%eax
8010496b:	29 d8                	sub    %ebx,%eax
}
8010496d:	5b                   	pop    %ebx
8010496e:	5e                   	pop    %esi
8010496f:	5d                   	pop    %ebp
80104970:	c3                   	ret    
80104971:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104978:	5b                   	pop    %ebx
    return 0;
80104979:	31 c0                	xor    %eax,%eax
}
8010497b:	5e                   	pop    %esi
8010497c:	5d                   	pop    %ebp
8010497d:	c3                   	ret    
8010497e:	66 90                	xchg   %ax,%ax

80104980 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104980:	f3 0f 1e fb          	endbr32 
80104984:	55                   	push   %ebp
80104985:	89 e5                	mov    %esp,%ebp
80104987:	57                   	push   %edi
80104988:	56                   	push   %esi
80104989:	8b 75 08             	mov    0x8(%ebp),%esi
8010498c:	53                   	push   %ebx
8010498d:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104990:	89 f2                	mov    %esi,%edx
80104992:	eb 1b                	jmp    801049af <strncpy+0x2f>
80104994:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104998:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010499c:	8b 7d 0c             	mov    0xc(%ebp),%edi
8010499f:	83 c2 01             	add    $0x1,%edx
801049a2:	0f b6 7f ff          	movzbl -0x1(%edi),%edi
801049a6:	89 f9                	mov    %edi,%ecx
801049a8:	88 4a ff             	mov    %cl,-0x1(%edx)
801049ab:	84 c9                	test   %cl,%cl
801049ad:	74 09                	je     801049b8 <strncpy+0x38>
801049af:	89 c3                	mov    %eax,%ebx
801049b1:	83 e8 01             	sub    $0x1,%eax
801049b4:	85 db                	test   %ebx,%ebx
801049b6:	7f e0                	jg     80104998 <strncpy+0x18>
    ;
  while(n-- > 0)
801049b8:	89 d1                	mov    %edx,%ecx
801049ba:	85 c0                	test   %eax,%eax
801049bc:	7e 15                	jle    801049d3 <strncpy+0x53>
801049be:	66 90                	xchg   %ax,%ax
    *s++ = 0;
801049c0:	83 c1 01             	add    $0x1,%ecx
801049c3:	c6 41 ff 00          	movb   $0x0,-0x1(%ecx)
  while(n-- > 0)
801049c7:	89 c8                	mov    %ecx,%eax
801049c9:	f7 d0                	not    %eax
801049cb:	01 d0                	add    %edx,%eax
801049cd:	01 d8                	add    %ebx,%eax
801049cf:	85 c0                	test   %eax,%eax
801049d1:	7f ed                	jg     801049c0 <strncpy+0x40>
  return os;
}
801049d3:	5b                   	pop    %ebx
801049d4:	89 f0                	mov    %esi,%eax
801049d6:	5e                   	pop    %esi
801049d7:	5f                   	pop    %edi
801049d8:	5d                   	pop    %ebp
801049d9:	c3                   	ret    
801049da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801049e0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801049e0:	f3 0f 1e fb          	endbr32 
801049e4:	55                   	push   %ebp
801049e5:	89 e5                	mov    %esp,%ebp
801049e7:	56                   	push   %esi
801049e8:	8b 55 10             	mov    0x10(%ebp),%edx
801049eb:	8b 75 08             	mov    0x8(%ebp),%esi
801049ee:	53                   	push   %ebx
801049ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
801049f2:	85 d2                	test   %edx,%edx
801049f4:	7e 21                	jle    80104a17 <safestrcpy+0x37>
801049f6:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
801049fa:	89 f2                	mov    %esi,%edx
801049fc:	eb 12                	jmp    80104a10 <safestrcpy+0x30>
801049fe:	66 90                	xchg   %ax,%ax
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104a00:	0f b6 08             	movzbl (%eax),%ecx
80104a03:	83 c0 01             	add    $0x1,%eax
80104a06:	83 c2 01             	add    $0x1,%edx
80104a09:	88 4a ff             	mov    %cl,-0x1(%edx)
80104a0c:	84 c9                	test   %cl,%cl
80104a0e:	74 04                	je     80104a14 <safestrcpy+0x34>
80104a10:	39 d8                	cmp    %ebx,%eax
80104a12:	75 ec                	jne    80104a00 <safestrcpy+0x20>
    ;
  *s = 0;
80104a14:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
80104a17:	89 f0                	mov    %esi,%eax
80104a19:	5b                   	pop    %ebx
80104a1a:	5e                   	pop    %esi
80104a1b:	5d                   	pop    %ebp
80104a1c:	c3                   	ret    
80104a1d:	8d 76 00             	lea    0x0(%esi),%esi

80104a20 <strlen>:

int
strlen(const char *s)
{
80104a20:	f3 0f 1e fb          	endbr32 
80104a24:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
80104a25:	31 c0                	xor    %eax,%eax
{
80104a27:	89 e5                	mov    %esp,%ebp
80104a29:	8b 55 08             	mov    0x8(%ebp),%edx
  for(n = 0; s[n]; n++)
80104a2c:	80 3a 00             	cmpb   $0x0,(%edx)
80104a2f:	74 10                	je     80104a41 <strlen+0x21>
80104a31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a38:	83 c0 01             	add    $0x1,%eax
80104a3b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104a3f:	75 f7                	jne    80104a38 <strlen+0x18>
    ;
  return n;
}
80104a41:	5d                   	pop    %ebp
80104a42:	c3                   	ret    

80104a43 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104a43:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104a47:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104a4b:	55                   	push   %ebp
  pushl %ebx
80104a4c:	53                   	push   %ebx
  pushl %esi
80104a4d:	56                   	push   %esi
  pushl %edi
80104a4e:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104a4f:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104a51:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104a53:	5f                   	pop    %edi
  popl %esi
80104a54:	5e                   	pop    %esi
  popl %ebx
80104a55:	5b                   	pop    %ebx
  popl %ebp
80104a56:	5d                   	pop    %ebp
  ret
80104a57:	c3                   	ret    
80104a58:	66 90                	xchg   %ax,%ax
80104a5a:	66 90                	xchg   %ax,%ax
80104a5c:	66 90                	xchg   %ax,%ax
80104a5e:	66 90                	xchg   %ax,%ax

80104a60 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104a60:	f3 0f 1e fb          	endbr32 
80104a64:	55                   	push   %ebp
80104a65:	89 e5                	mov    %esp,%ebp
80104a67:	53                   	push   %ebx
80104a68:	83 ec 04             	sub    $0x4,%esp
80104a6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80104a6e:	e8 cd f0 ff ff       	call   80103b40 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104a73:	8b 00                	mov    (%eax),%eax
80104a75:	39 d8                	cmp    %ebx,%eax
80104a77:	76 17                	jbe    80104a90 <fetchint+0x30>
80104a79:	8d 53 04             	lea    0x4(%ebx),%edx
80104a7c:	39 d0                	cmp    %edx,%eax
80104a7e:	72 10                	jb     80104a90 <fetchint+0x30>
    return -1;
  *ip = *(int*)(addr);
80104a80:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a83:	8b 13                	mov    (%ebx),%edx
80104a85:	89 10                	mov    %edx,(%eax)
  return 0;
80104a87:	31 c0                	xor    %eax,%eax
}
80104a89:	83 c4 04             	add    $0x4,%esp
80104a8c:	5b                   	pop    %ebx
80104a8d:	5d                   	pop    %ebp
80104a8e:	c3                   	ret    
80104a8f:	90                   	nop
    return -1;
80104a90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a95:	eb f2                	jmp    80104a89 <fetchint+0x29>
80104a97:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a9e:	66 90                	xchg   %ax,%ax

80104aa0 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104aa0:	f3 0f 1e fb          	endbr32 
80104aa4:	55                   	push   %ebp
80104aa5:	89 e5                	mov    %esp,%ebp
80104aa7:	53                   	push   %ebx
80104aa8:	83 ec 04             	sub    $0x4,%esp
80104aab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80104aae:	e8 8d f0 ff ff       	call   80103b40 <myproc>

  if(addr >= curproc->sz)
80104ab3:	39 18                	cmp    %ebx,(%eax)
80104ab5:	76 31                	jbe    80104ae8 <fetchstr+0x48>
    return -1;
  *pp = (char*)addr;
80104ab7:	8b 55 0c             	mov    0xc(%ebp),%edx
80104aba:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104abc:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104abe:	39 d3                	cmp    %edx,%ebx
80104ac0:	73 26                	jae    80104ae8 <fetchstr+0x48>
80104ac2:	89 d8                	mov    %ebx,%eax
80104ac4:	eb 11                	jmp    80104ad7 <fetchstr+0x37>
80104ac6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104acd:	8d 76 00             	lea    0x0(%esi),%esi
80104ad0:	83 c0 01             	add    $0x1,%eax
80104ad3:	39 c2                	cmp    %eax,%edx
80104ad5:	76 11                	jbe    80104ae8 <fetchstr+0x48>
    if(*s == 0)
80104ad7:	80 38 00             	cmpb   $0x0,(%eax)
80104ada:	75 f4                	jne    80104ad0 <fetchstr+0x30>
      return s - *pp;
  }
  return -1;
}
80104adc:	83 c4 04             	add    $0x4,%esp
      return s - *pp;
80104adf:	29 d8                	sub    %ebx,%eax
}
80104ae1:	5b                   	pop    %ebx
80104ae2:	5d                   	pop    %ebp
80104ae3:	c3                   	ret    
80104ae4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104ae8:	83 c4 04             	add    $0x4,%esp
    return -1;
80104aeb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104af0:	5b                   	pop    %ebx
80104af1:	5d                   	pop    %ebp
80104af2:	c3                   	ret    
80104af3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104afa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104b00 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104b00:	f3 0f 1e fb          	endbr32 
80104b04:	55                   	push   %ebp
80104b05:	89 e5                	mov    %esp,%ebp
80104b07:	56                   	push   %esi
80104b08:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104b09:	e8 32 f0 ff ff       	call   80103b40 <myproc>
80104b0e:	8b 55 08             	mov    0x8(%ebp),%edx
80104b11:	8b 40 18             	mov    0x18(%eax),%eax
80104b14:	8b 40 44             	mov    0x44(%eax),%eax
80104b17:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104b1a:	e8 21 f0 ff ff       	call   80103b40 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104b1f:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104b22:	8b 00                	mov    (%eax),%eax
80104b24:	39 c6                	cmp    %eax,%esi
80104b26:	73 18                	jae    80104b40 <argint+0x40>
80104b28:	8d 53 08             	lea    0x8(%ebx),%edx
80104b2b:	39 d0                	cmp    %edx,%eax
80104b2d:	72 11                	jb     80104b40 <argint+0x40>
  *ip = *(int*)(addr);
80104b2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b32:	8b 53 04             	mov    0x4(%ebx),%edx
80104b35:	89 10                	mov    %edx,(%eax)
  return 0;
80104b37:	31 c0                	xor    %eax,%eax
}
80104b39:	5b                   	pop    %ebx
80104b3a:	5e                   	pop    %esi
80104b3b:	5d                   	pop    %ebp
80104b3c:	c3                   	ret    
80104b3d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80104b40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104b45:	eb f2                	jmp    80104b39 <argint+0x39>
80104b47:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104b4e:	66 90                	xchg   %ax,%ax

80104b50 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104b50:	f3 0f 1e fb          	endbr32 
80104b54:	55                   	push   %ebp
80104b55:	89 e5                	mov    %esp,%ebp
80104b57:	56                   	push   %esi
80104b58:	53                   	push   %ebx
80104b59:	83 ec 10             	sub    $0x10,%esp
80104b5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80104b5f:	e8 dc ef ff ff       	call   80103b40 <myproc>

  if(argint(n, &i) < 0)
80104b64:	83 ec 08             	sub    $0x8,%esp
  struct proc *curproc = myproc();
80104b67:	89 c6                	mov    %eax,%esi
  if(argint(n, &i) < 0)
80104b69:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b6c:	50                   	push   %eax
80104b6d:	ff 75 08             	pushl  0x8(%ebp)
80104b70:	e8 8b ff ff ff       	call   80104b00 <argint>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104b75:	83 c4 10             	add    $0x10,%esp
80104b78:	85 c0                	test   %eax,%eax
80104b7a:	78 24                	js     80104ba0 <argptr+0x50>
80104b7c:	85 db                	test   %ebx,%ebx
80104b7e:	78 20                	js     80104ba0 <argptr+0x50>
80104b80:	8b 16                	mov    (%esi),%edx
80104b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b85:	39 c2                	cmp    %eax,%edx
80104b87:	76 17                	jbe    80104ba0 <argptr+0x50>
80104b89:	01 c3                	add    %eax,%ebx
80104b8b:	39 da                	cmp    %ebx,%edx
80104b8d:	72 11                	jb     80104ba0 <argptr+0x50>
    return -1;
  *pp = (char*)i;
80104b8f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b92:	89 02                	mov    %eax,(%edx)
  return 0;
80104b94:	31 c0                	xor    %eax,%eax
}
80104b96:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104b99:	5b                   	pop    %ebx
80104b9a:	5e                   	pop    %esi
80104b9b:	5d                   	pop    %ebp
80104b9c:	c3                   	ret    
80104b9d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80104ba0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ba5:	eb ef                	jmp    80104b96 <argptr+0x46>
80104ba7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104bae:	66 90                	xchg   %ax,%ax

80104bb0 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104bb0:	f3 0f 1e fb          	endbr32 
80104bb4:	55                   	push   %ebp
80104bb5:	89 e5                	mov    %esp,%ebp
80104bb7:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104bba:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104bbd:	50                   	push   %eax
80104bbe:	ff 75 08             	pushl  0x8(%ebp)
80104bc1:	e8 3a ff ff ff       	call   80104b00 <argint>
80104bc6:	83 c4 10             	add    $0x10,%esp
80104bc9:	85 c0                	test   %eax,%eax
80104bcb:	78 13                	js     80104be0 <argstr+0x30>
    return -1;
  return fetchstr(addr, pp);
80104bcd:	83 ec 08             	sub    $0x8,%esp
80104bd0:	ff 75 0c             	pushl  0xc(%ebp)
80104bd3:	ff 75 f4             	pushl  -0xc(%ebp)
80104bd6:	e8 c5 fe ff ff       	call   80104aa0 <fetchstr>
80104bdb:	83 c4 10             	add    $0x10,%esp
}
80104bde:	c9                   	leave  
80104bdf:	c3                   	ret    
80104be0:	c9                   	leave  
    return -1;
80104be1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104be6:	c3                   	ret    
80104be7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104bee:	66 90                	xchg   %ax,%ax

80104bf0 <syscall>:
[SYS_swap]    sys_swap,
};

void
syscall(void)
{
80104bf0:	f3 0f 1e fb          	endbr32 
80104bf4:	55                   	push   %ebp
80104bf5:	89 e5                	mov    %esp,%ebp
80104bf7:	53                   	push   %ebx
80104bf8:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104bfb:	e8 40 ef ff ff       	call   80103b40 <myproc>
80104c00:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104c02:	8b 40 18             	mov    0x18(%eax),%eax
80104c05:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104c08:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c0b:	83 fa 16             	cmp    $0x16,%edx
80104c0e:	77 20                	ja     80104c30 <syscall+0x40>
80104c10:	8b 14 85 00 81 10 80 	mov    -0x7fef7f00(,%eax,4),%edx
80104c17:	85 d2                	test   %edx,%edx
80104c19:	74 15                	je     80104c30 <syscall+0x40>
    curproc->tf->eax = syscalls[num]();
80104c1b:	ff d2                	call   *%edx
80104c1d:	89 c2                	mov    %eax,%edx
80104c1f:	8b 43 18             	mov    0x18(%ebx),%eax
80104c22:	89 50 1c             	mov    %edx,0x1c(%eax)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104c25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c28:	c9                   	leave  
80104c29:	c3                   	ret    
80104c2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    cprintf("%d %s: unknown sys call %d\n",
80104c30:	8b 53 10             	mov    0x10(%ebx),%edx
80104c33:	50                   	push   %eax
            curproc->pid, curproc->name, num);
80104c34:	8d 43 6c             	lea    0x6c(%ebx),%eax
    cprintf("%d %s: unknown sys call %d\n",
80104c37:	50                   	push   %eax
80104c38:	52                   	push   %edx
80104c39:	68 dd 80 10 80       	push   $0x801080dd
80104c3e:	e8 5d bb ff ff       	call   801007a0 <cprintf>
    curproc->tf->eax = -1;
80104c43:	8b 43 18             	mov    0x18(%ebx),%eax
80104c46:	83 c4 10             	add    $0x10,%esp
80104c49:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
}
80104c50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c53:	c9                   	leave  
80104c54:	c3                   	ret    
80104c55:	66 90                	xchg   %ax,%ax
80104c57:	66 90                	xchg   %ax,%ax
80104c59:	66 90                	xchg   %ax,%ax
80104c5b:	66 90                	xchg   %ax,%ax
80104c5d:	66 90                	xchg   %ax,%ax
80104c5f:	90                   	nop

80104c60 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104c60:	55                   	push   %ebp
80104c61:	89 e5                	mov    %esp,%ebp
80104c63:	57                   	push   %edi
80104c64:	56                   	push   %esi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104c65:	8d 7d da             	lea    -0x26(%ebp),%edi
{
80104c68:	53                   	push   %ebx
80104c69:	83 ec 44             	sub    $0x44,%esp
80104c6c:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80104c6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if((dp = nameiparent(path, name)) == 0)
80104c72:	57                   	push   %edi
80104c73:	50                   	push   %eax
{
80104c74:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80104c77:	89 4d bc             	mov    %ecx,-0x44(%ebp)
  if((dp = nameiparent(path, name)) == 0)
80104c7a:	e8 b1 d5 ff ff       	call   80102230 <nameiparent>
80104c7f:	83 c4 10             	add    $0x10,%esp
80104c82:	85 c0                	test   %eax,%eax
80104c84:	0f 84 46 01 00 00    	je     80104dd0 <create+0x170>
    return 0;
  ilock(dp);
80104c8a:	83 ec 0c             	sub    $0xc,%esp
80104c8d:	89 c3                	mov    %eax,%ebx
80104c8f:	50                   	push   %eax
80104c90:	e8 ab cc ff ff       	call   80101940 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80104c95:	83 c4 0c             	add    $0xc,%esp
80104c98:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80104c9b:	50                   	push   %eax
80104c9c:	57                   	push   %edi
80104c9d:	53                   	push   %ebx
80104c9e:	e8 ed d1 ff ff       	call   80101e90 <dirlookup>
80104ca3:	83 c4 10             	add    $0x10,%esp
80104ca6:	89 c6                	mov    %eax,%esi
80104ca8:	85 c0                	test   %eax,%eax
80104caa:	74 54                	je     80104d00 <create+0xa0>
    iunlockput(dp);
80104cac:	83 ec 0c             	sub    $0xc,%esp
80104caf:	53                   	push   %ebx
80104cb0:	e8 2b cf ff ff       	call   80101be0 <iunlockput>
    ilock(ip);
80104cb5:	89 34 24             	mov    %esi,(%esp)
80104cb8:	e8 83 cc ff ff       	call   80101940 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104cbd:	83 c4 10             	add    $0x10,%esp
80104cc0:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
80104cc5:	75 19                	jne    80104ce0 <create+0x80>
80104cc7:	66 83 7e 50 02       	cmpw   $0x2,0x50(%esi)
80104ccc:	75 12                	jne    80104ce0 <create+0x80>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104cce:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104cd1:	89 f0                	mov    %esi,%eax
80104cd3:	5b                   	pop    %ebx
80104cd4:	5e                   	pop    %esi
80104cd5:	5f                   	pop    %edi
80104cd6:	5d                   	pop    %ebp
80104cd7:	c3                   	ret    
80104cd8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104cdf:	90                   	nop
    iunlockput(ip);
80104ce0:	83 ec 0c             	sub    $0xc,%esp
80104ce3:	56                   	push   %esi
    return 0;
80104ce4:	31 f6                	xor    %esi,%esi
    iunlockput(ip);
80104ce6:	e8 f5 ce ff ff       	call   80101be0 <iunlockput>
    return 0;
80104ceb:	83 c4 10             	add    $0x10,%esp
}
80104cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104cf1:	89 f0                	mov    %esi,%eax
80104cf3:	5b                   	pop    %ebx
80104cf4:	5e                   	pop    %esi
80104cf5:	5f                   	pop    %edi
80104cf6:	5d                   	pop    %ebp
80104cf7:	c3                   	ret    
80104cf8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104cff:	90                   	nop
  if((ip = ialloc(dp->dev, type)) == 0)
80104d00:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
80104d04:	83 ec 08             	sub    $0x8,%esp
80104d07:	50                   	push   %eax
80104d08:	ff 33                	pushl  (%ebx)
80104d0a:	e8 b1 ca ff ff       	call   801017c0 <ialloc>
80104d0f:	83 c4 10             	add    $0x10,%esp
80104d12:	89 c6                	mov    %eax,%esi
80104d14:	85 c0                	test   %eax,%eax
80104d16:	0f 84 cd 00 00 00    	je     80104de9 <create+0x189>
  ilock(ip);
80104d1c:	83 ec 0c             	sub    $0xc,%esp
80104d1f:	50                   	push   %eax
80104d20:	e8 1b cc ff ff       	call   80101940 <ilock>
  ip->major = major;
80104d25:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80104d29:	66 89 46 52          	mov    %ax,0x52(%esi)
  ip->minor = minor;
80104d2d:	0f b7 45 bc          	movzwl -0x44(%ebp),%eax
80104d31:	66 89 46 54          	mov    %ax,0x54(%esi)
  ip->nlink = 1;
80104d35:	b8 01 00 00 00       	mov    $0x1,%eax
80104d3a:	66 89 46 56          	mov    %ax,0x56(%esi)
  iupdate(ip);
80104d3e:	89 34 24             	mov    %esi,(%esp)
80104d41:	e8 3a cb ff ff       	call   80101880 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104d46:	83 c4 10             	add    $0x10,%esp
80104d49:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
80104d4e:	74 30                	je     80104d80 <create+0x120>
  if(dirlink(dp, name, ip->inum) < 0)
80104d50:	83 ec 04             	sub    $0x4,%esp
80104d53:	ff 76 04             	pushl  0x4(%esi)
80104d56:	57                   	push   %edi
80104d57:	53                   	push   %ebx
80104d58:	e8 f3 d3 ff ff       	call   80102150 <dirlink>
80104d5d:	83 c4 10             	add    $0x10,%esp
80104d60:	85 c0                	test   %eax,%eax
80104d62:	78 78                	js     80104ddc <create+0x17c>
  iunlockput(dp);
80104d64:	83 ec 0c             	sub    $0xc,%esp
80104d67:	53                   	push   %ebx
80104d68:	e8 73 ce ff ff       	call   80101be0 <iunlockput>
  return ip;
80104d6d:	83 c4 10             	add    $0x10,%esp
}
80104d70:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104d73:	89 f0                	mov    %esi,%eax
80104d75:	5b                   	pop    %ebx
80104d76:	5e                   	pop    %esi
80104d77:	5f                   	pop    %edi
80104d78:	5d                   	pop    %ebp
80104d79:	c3                   	ret    
80104d7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iupdate(dp);
80104d80:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink++;  // for ".."
80104d83:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
    iupdate(dp);
80104d88:	53                   	push   %ebx
80104d89:	e8 f2 ca ff ff       	call   80101880 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104d8e:	83 c4 0c             	add    $0xc,%esp
80104d91:	ff 76 04             	pushl  0x4(%esi)
80104d94:	68 7c 81 10 80       	push   $0x8010817c
80104d99:	56                   	push   %esi
80104d9a:	e8 b1 d3 ff ff       	call   80102150 <dirlink>
80104d9f:	83 c4 10             	add    $0x10,%esp
80104da2:	85 c0                	test   %eax,%eax
80104da4:	78 18                	js     80104dbe <create+0x15e>
80104da6:	83 ec 04             	sub    $0x4,%esp
80104da9:	ff 73 04             	pushl  0x4(%ebx)
80104dac:	68 7b 81 10 80       	push   $0x8010817b
80104db1:	56                   	push   %esi
80104db2:	e8 99 d3 ff ff       	call   80102150 <dirlink>
80104db7:	83 c4 10             	add    $0x10,%esp
80104dba:	85 c0                	test   %eax,%eax
80104dbc:	79 92                	jns    80104d50 <create+0xf0>
      panic("create dots");
80104dbe:	83 ec 0c             	sub    $0xc,%esp
80104dc1:	68 6f 81 10 80       	push   $0x8010816f
80104dc6:	e8 b5 b6 ff ff       	call   80100480 <panic>
80104dcb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104dcf:	90                   	nop
}
80104dd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80104dd3:	31 f6                	xor    %esi,%esi
}
80104dd5:	5b                   	pop    %ebx
80104dd6:	89 f0                	mov    %esi,%eax
80104dd8:	5e                   	pop    %esi
80104dd9:	5f                   	pop    %edi
80104dda:	5d                   	pop    %ebp
80104ddb:	c3                   	ret    
    panic("create: dirlink");
80104ddc:	83 ec 0c             	sub    $0xc,%esp
80104ddf:	68 7e 81 10 80       	push   $0x8010817e
80104de4:	e8 97 b6 ff ff       	call   80100480 <panic>
    panic("create: ialloc");
80104de9:	83 ec 0c             	sub    $0xc,%esp
80104dec:	68 60 81 10 80       	push   $0x80108160
80104df1:	e8 8a b6 ff ff       	call   80100480 <panic>
80104df6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104dfd:	8d 76 00             	lea    0x0(%esi),%esi

80104e00 <argfd.constprop.0>:
argfd(int n, int *pfd, struct file **pf)
80104e00:	55                   	push   %ebp
80104e01:	89 e5                	mov    %esp,%ebp
80104e03:	56                   	push   %esi
80104e04:	89 d6                	mov    %edx,%esi
80104e06:	53                   	push   %ebx
80104e07:	89 c3                	mov    %eax,%ebx
  if(argint(n, &fd) < 0)
80104e09:	8d 45 f4             	lea    -0xc(%ebp),%eax
argfd(int n, int *pfd, struct file **pf)
80104e0c:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80104e0f:	50                   	push   %eax
80104e10:	6a 00                	push   $0x0
80104e12:	e8 e9 fc ff ff       	call   80104b00 <argint>
80104e17:	83 c4 10             	add    $0x10,%esp
80104e1a:	85 c0                	test   %eax,%eax
80104e1c:	78 2a                	js     80104e48 <argfd.constprop.0+0x48>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104e1e:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104e22:	77 24                	ja     80104e48 <argfd.constprop.0+0x48>
80104e24:	e8 17 ed ff ff       	call   80103b40 <myproc>
80104e29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e2c:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104e30:	85 c0                	test   %eax,%eax
80104e32:	74 14                	je     80104e48 <argfd.constprop.0+0x48>
  if(pfd)
80104e34:	85 db                	test   %ebx,%ebx
80104e36:	74 02                	je     80104e3a <argfd.constprop.0+0x3a>
    *pfd = fd;
80104e38:	89 13                	mov    %edx,(%ebx)
    *pf = f;
80104e3a:	89 06                	mov    %eax,(%esi)
  return 0;
80104e3c:	31 c0                	xor    %eax,%eax
}
80104e3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104e41:	5b                   	pop    %ebx
80104e42:	5e                   	pop    %esi
80104e43:	5d                   	pop    %ebp
80104e44:	c3                   	ret    
80104e45:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80104e48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e4d:	eb ef                	jmp    80104e3e <argfd.constprop.0+0x3e>
80104e4f:	90                   	nop

80104e50 <sys_dup>:
{
80104e50:	f3 0f 1e fb          	endbr32 
80104e54:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0)
80104e55:	31 c0                	xor    %eax,%eax
{
80104e57:	89 e5                	mov    %esp,%ebp
80104e59:	56                   	push   %esi
80104e5a:	53                   	push   %ebx
  if(argfd(0, 0, &f) < 0)
80104e5b:	8d 55 f4             	lea    -0xc(%ebp),%edx
{
80104e5e:	83 ec 10             	sub    $0x10,%esp
  if(argfd(0, 0, &f) < 0)
80104e61:	e8 9a ff ff ff       	call   80104e00 <argfd.constprop.0>
80104e66:	85 c0                	test   %eax,%eax
80104e68:	78 1e                	js     80104e88 <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
80104e6a:	8b 75 f4             	mov    -0xc(%ebp),%esi
  for(fd = 0; fd < NOFILE; fd++){
80104e6d:	31 db                	xor    %ebx,%ebx
  struct proc *curproc = myproc();
80104e6f:	e8 cc ec ff ff       	call   80103b40 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80104e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[fd] == 0){
80104e78:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
80104e7c:	85 d2                	test   %edx,%edx
80104e7e:	74 20                	je     80104ea0 <sys_dup+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80104e80:	83 c3 01             	add    $0x1,%ebx
80104e83:	83 fb 10             	cmp    $0x10,%ebx
80104e86:	75 f0                	jne    80104e78 <sys_dup+0x28>
}
80104e88:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return -1;
80104e8b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
80104e90:	89 d8                	mov    %ebx,%eax
80104e92:	5b                   	pop    %ebx
80104e93:	5e                   	pop    %esi
80104e94:	5d                   	pop    %ebp
80104e95:	c3                   	ret    
80104e96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104e9d:	8d 76 00             	lea    0x0(%esi),%esi
      curproc->ofile[fd] = f;
80104ea0:	89 74 98 28          	mov    %esi,0x28(%eax,%ebx,4)
  filedup(f);
80104ea4:	83 ec 0c             	sub    $0xc,%esp
80104ea7:	ff 75 f4             	pushl  -0xc(%ebp)
80104eaa:	e8 b1 c0 ff ff       	call   80100f60 <filedup>
  return fd;
80104eaf:	83 c4 10             	add    $0x10,%esp
}
80104eb2:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104eb5:	89 d8                	mov    %ebx,%eax
80104eb7:	5b                   	pop    %ebx
80104eb8:	5e                   	pop    %esi
80104eb9:	5d                   	pop    %ebp
80104eba:	c3                   	ret    
80104ebb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104ebf:	90                   	nop

80104ec0 <sys_read>:
{
80104ec0:	f3 0f 1e fb          	endbr32 
80104ec4:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104ec5:	31 c0                	xor    %eax,%eax
{
80104ec7:	89 e5                	mov    %esp,%ebp
80104ec9:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104ecc:	8d 55 ec             	lea    -0x14(%ebp),%edx
80104ecf:	e8 2c ff ff ff       	call   80104e00 <argfd.constprop.0>
80104ed4:	85 c0                	test   %eax,%eax
80104ed6:	78 48                	js     80104f20 <sys_read+0x60>
80104ed8:	83 ec 08             	sub    $0x8,%esp
80104edb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ede:	50                   	push   %eax
80104edf:	6a 02                	push   $0x2
80104ee1:	e8 1a fc ff ff       	call   80104b00 <argint>
80104ee6:	83 c4 10             	add    $0x10,%esp
80104ee9:	85 c0                	test   %eax,%eax
80104eeb:	78 33                	js     80104f20 <sys_read+0x60>
80104eed:	83 ec 04             	sub    $0x4,%esp
80104ef0:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ef3:	ff 75 f0             	pushl  -0x10(%ebp)
80104ef6:	50                   	push   %eax
80104ef7:	6a 01                	push   $0x1
80104ef9:	e8 52 fc ff ff       	call   80104b50 <argptr>
80104efe:	83 c4 10             	add    $0x10,%esp
80104f01:	85 c0                	test   %eax,%eax
80104f03:	78 1b                	js     80104f20 <sys_read+0x60>
  return fileread(f, p, n);
80104f05:	83 ec 04             	sub    $0x4,%esp
80104f08:	ff 75 f0             	pushl  -0x10(%ebp)
80104f0b:	ff 75 f4             	pushl  -0xc(%ebp)
80104f0e:	ff 75 ec             	pushl  -0x14(%ebp)
80104f11:	e8 ca c1 ff ff       	call   801010e0 <fileread>
80104f16:	83 c4 10             	add    $0x10,%esp
}
80104f19:	c9                   	leave  
80104f1a:	c3                   	ret    
80104f1b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104f1f:	90                   	nop
80104f20:	c9                   	leave  
    return -1;
80104f21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f26:	c3                   	ret    
80104f27:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104f2e:	66 90                	xchg   %ax,%ax

80104f30 <sys_write>:
{
80104f30:	f3 0f 1e fb          	endbr32 
80104f34:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104f35:	31 c0                	xor    %eax,%eax
{
80104f37:	89 e5                	mov    %esp,%ebp
80104f39:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104f3c:	8d 55 ec             	lea    -0x14(%ebp),%edx
80104f3f:	e8 bc fe ff ff       	call   80104e00 <argfd.constprop.0>
80104f44:	85 c0                	test   %eax,%eax
80104f46:	78 48                	js     80104f90 <sys_write+0x60>
80104f48:	83 ec 08             	sub    $0x8,%esp
80104f4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f4e:	50                   	push   %eax
80104f4f:	6a 02                	push   $0x2
80104f51:	e8 aa fb ff ff       	call   80104b00 <argint>
80104f56:	83 c4 10             	add    $0x10,%esp
80104f59:	85 c0                	test   %eax,%eax
80104f5b:	78 33                	js     80104f90 <sys_write+0x60>
80104f5d:	83 ec 04             	sub    $0x4,%esp
80104f60:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f63:	ff 75 f0             	pushl  -0x10(%ebp)
80104f66:	50                   	push   %eax
80104f67:	6a 01                	push   $0x1
80104f69:	e8 e2 fb ff ff       	call   80104b50 <argptr>
80104f6e:	83 c4 10             	add    $0x10,%esp
80104f71:	85 c0                	test   %eax,%eax
80104f73:	78 1b                	js     80104f90 <sys_write+0x60>
  return filewrite(f, p, n);
80104f75:	83 ec 04             	sub    $0x4,%esp
80104f78:	ff 75 f0             	pushl  -0x10(%ebp)
80104f7b:	ff 75 f4             	pushl  -0xc(%ebp)
80104f7e:	ff 75 ec             	pushl  -0x14(%ebp)
80104f81:	e8 fa c1 ff ff       	call   80101180 <filewrite>
80104f86:	83 c4 10             	add    $0x10,%esp
}
80104f89:	c9                   	leave  
80104f8a:	c3                   	ret    
80104f8b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104f8f:	90                   	nop
80104f90:	c9                   	leave  
    return -1;
80104f91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f96:	c3                   	ret    
80104f97:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104f9e:	66 90                	xchg   %ax,%ax

80104fa0 <sys_close>:
{
80104fa0:	f3 0f 1e fb          	endbr32 
80104fa4:	55                   	push   %ebp
80104fa5:	89 e5                	mov    %esp,%ebp
80104fa7:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80104faa:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104fad:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104fb0:	e8 4b fe ff ff       	call   80104e00 <argfd.constprop.0>
80104fb5:	85 c0                	test   %eax,%eax
80104fb7:	78 27                	js     80104fe0 <sys_close+0x40>
  myproc()->ofile[fd] = 0;
80104fb9:	e8 82 eb ff ff       	call   80103b40 <myproc>
80104fbe:	8b 55 f0             	mov    -0x10(%ebp),%edx
  fileclose(f);
80104fc1:	83 ec 0c             	sub    $0xc,%esp
  myproc()->ofile[fd] = 0;
80104fc4:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
80104fcb:	00 
  fileclose(f);
80104fcc:	ff 75 f4             	pushl  -0xc(%ebp)
80104fcf:	e8 dc bf ff ff       	call   80100fb0 <fileclose>
  return 0;
80104fd4:	83 c4 10             	add    $0x10,%esp
80104fd7:	31 c0                	xor    %eax,%eax
}
80104fd9:	c9                   	leave  
80104fda:	c3                   	ret    
80104fdb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104fdf:	90                   	nop
80104fe0:	c9                   	leave  
    return -1;
80104fe1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104fe6:	c3                   	ret    
80104fe7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104fee:	66 90                	xchg   %ax,%ax

80104ff0 <sys_fstat>:
{
80104ff0:	f3 0f 1e fb          	endbr32 
80104ff4:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104ff5:	31 c0                	xor    %eax,%eax
{
80104ff7:	89 e5                	mov    %esp,%ebp
80104ff9:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104ffc:	8d 55 f0             	lea    -0x10(%ebp),%edx
80104fff:	e8 fc fd ff ff       	call   80104e00 <argfd.constprop.0>
80105004:	85 c0                	test   %eax,%eax
80105006:	78 30                	js     80105038 <sys_fstat+0x48>
80105008:	83 ec 04             	sub    $0x4,%esp
8010500b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010500e:	6a 14                	push   $0x14
80105010:	50                   	push   %eax
80105011:	6a 01                	push   $0x1
80105013:	e8 38 fb ff ff       	call   80104b50 <argptr>
80105018:	83 c4 10             	add    $0x10,%esp
8010501b:	85 c0                	test   %eax,%eax
8010501d:	78 19                	js     80105038 <sys_fstat+0x48>
  return filestat(f, st);
8010501f:	83 ec 08             	sub    $0x8,%esp
80105022:	ff 75 f4             	pushl  -0xc(%ebp)
80105025:	ff 75 f0             	pushl  -0x10(%ebp)
80105028:	e8 63 c0 ff ff       	call   80101090 <filestat>
8010502d:	83 c4 10             	add    $0x10,%esp
}
80105030:	c9                   	leave  
80105031:	c3                   	ret    
80105032:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105038:	c9                   	leave  
    return -1;
80105039:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010503e:	c3                   	ret    
8010503f:	90                   	nop

80105040 <sys_link>:
{
80105040:	f3 0f 1e fb          	endbr32 
80105044:	55                   	push   %ebp
80105045:	89 e5                	mov    %esp,%ebp
80105047:	57                   	push   %edi
80105048:	56                   	push   %esi
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105049:	8d 45 d4             	lea    -0x2c(%ebp),%eax
{
8010504c:	53                   	push   %ebx
8010504d:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105050:	50                   	push   %eax
80105051:	6a 00                	push   $0x0
80105053:	e8 58 fb ff ff       	call   80104bb0 <argstr>
80105058:	83 c4 10             	add    $0x10,%esp
8010505b:	85 c0                	test   %eax,%eax
8010505d:	0f 88 ff 00 00 00    	js     80105162 <sys_link+0x122>
80105063:	83 ec 08             	sub    $0x8,%esp
80105066:	8d 45 d0             	lea    -0x30(%ebp),%eax
80105069:	50                   	push   %eax
8010506a:	6a 01                	push   $0x1
8010506c:	e8 3f fb ff ff       	call   80104bb0 <argstr>
80105071:	83 c4 10             	add    $0x10,%esp
80105074:	85 c0                	test   %eax,%eax
80105076:	0f 88 e6 00 00 00    	js     80105162 <sys_link+0x122>
  begin_op();
8010507c:	e8 7f de ff ff       	call   80102f00 <begin_op>
  if((ip = namei(old)) == 0){
80105081:	83 ec 0c             	sub    $0xc,%esp
80105084:	ff 75 d4             	pushl  -0x2c(%ebp)
80105087:	e8 84 d1 ff ff       	call   80102210 <namei>
8010508c:	83 c4 10             	add    $0x10,%esp
8010508f:	89 c3                	mov    %eax,%ebx
80105091:	85 c0                	test   %eax,%eax
80105093:	0f 84 e8 00 00 00    	je     80105181 <sys_link+0x141>
  ilock(ip);
80105099:	83 ec 0c             	sub    $0xc,%esp
8010509c:	50                   	push   %eax
8010509d:	e8 9e c8 ff ff       	call   80101940 <ilock>
  if(ip->type == T_DIR){
801050a2:	83 c4 10             	add    $0x10,%esp
801050a5:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801050aa:	0f 84 b9 00 00 00    	je     80105169 <sys_link+0x129>
  iupdate(ip);
801050b0:	83 ec 0c             	sub    $0xc,%esp
  ip->nlink++;
801050b3:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
  if((dp = nameiparent(new, name)) == 0)
801050b8:	8d 7d da             	lea    -0x26(%ebp),%edi
  iupdate(ip);
801050bb:	53                   	push   %ebx
801050bc:	e8 bf c7 ff ff       	call   80101880 <iupdate>
  iunlock(ip);
801050c1:	89 1c 24             	mov    %ebx,(%esp)
801050c4:	e8 57 c9 ff ff       	call   80101a20 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801050c9:	58                   	pop    %eax
801050ca:	5a                   	pop    %edx
801050cb:	57                   	push   %edi
801050cc:	ff 75 d0             	pushl  -0x30(%ebp)
801050cf:	e8 5c d1 ff ff       	call   80102230 <nameiparent>
801050d4:	83 c4 10             	add    $0x10,%esp
801050d7:	89 c6                	mov    %eax,%esi
801050d9:	85 c0                	test   %eax,%eax
801050db:	74 5f                	je     8010513c <sys_link+0xfc>
  ilock(dp);
801050dd:	83 ec 0c             	sub    $0xc,%esp
801050e0:	50                   	push   %eax
801050e1:	e8 5a c8 ff ff       	call   80101940 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801050e6:	8b 03                	mov    (%ebx),%eax
801050e8:	83 c4 10             	add    $0x10,%esp
801050eb:	39 06                	cmp    %eax,(%esi)
801050ed:	75 41                	jne    80105130 <sys_link+0xf0>
801050ef:	83 ec 04             	sub    $0x4,%esp
801050f2:	ff 73 04             	pushl  0x4(%ebx)
801050f5:	57                   	push   %edi
801050f6:	56                   	push   %esi
801050f7:	e8 54 d0 ff ff       	call   80102150 <dirlink>
801050fc:	83 c4 10             	add    $0x10,%esp
801050ff:	85 c0                	test   %eax,%eax
80105101:	78 2d                	js     80105130 <sys_link+0xf0>
  iunlockput(dp);
80105103:	83 ec 0c             	sub    $0xc,%esp
80105106:	56                   	push   %esi
80105107:	e8 d4 ca ff ff       	call   80101be0 <iunlockput>
  iput(ip);
8010510c:	89 1c 24             	mov    %ebx,(%esp)
8010510f:	e8 5c c9 ff ff       	call   80101a70 <iput>
  end_op();
80105114:	e8 57 de ff ff       	call   80102f70 <end_op>
  return 0;
80105119:	83 c4 10             	add    $0x10,%esp
8010511c:	31 c0                	xor    %eax,%eax
}
8010511e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105121:	5b                   	pop    %ebx
80105122:	5e                   	pop    %esi
80105123:	5f                   	pop    %edi
80105124:	5d                   	pop    %ebp
80105125:	c3                   	ret    
80105126:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010512d:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(dp);
80105130:	83 ec 0c             	sub    $0xc,%esp
80105133:	56                   	push   %esi
80105134:	e8 a7 ca ff ff       	call   80101be0 <iunlockput>
    goto bad;
80105139:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
8010513c:	83 ec 0c             	sub    $0xc,%esp
8010513f:	53                   	push   %ebx
80105140:	e8 fb c7 ff ff       	call   80101940 <ilock>
  ip->nlink--;
80105145:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
8010514a:	89 1c 24             	mov    %ebx,(%esp)
8010514d:	e8 2e c7 ff ff       	call   80101880 <iupdate>
  iunlockput(ip);
80105152:	89 1c 24             	mov    %ebx,(%esp)
80105155:	e8 86 ca ff ff       	call   80101be0 <iunlockput>
  end_op();
8010515a:	e8 11 de ff ff       	call   80102f70 <end_op>
  return -1;
8010515f:	83 c4 10             	add    $0x10,%esp
80105162:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105167:	eb b5                	jmp    8010511e <sys_link+0xde>
    iunlockput(ip);
80105169:	83 ec 0c             	sub    $0xc,%esp
8010516c:	53                   	push   %ebx
8010516d:	e8 6e ca ff ff       	call   80101be0 <iunlockput>
    end_op();
80105172:	e8 f9 dd ff ff       	call   80102f70 <end_op>
    return -1;
80105177:	83 c4 10             	add    $0x10,%esp
8010517a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010517f:	eb 9d                	jmp    8010511e <sys_link+0xde>
    end_op();
80105181:	e8 ea dd ff ff       	call   80102f70 <end_op>
    return -1;
80105186:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010518b:	eb 91                	jmp    8010511e <sys_link+0xde>
8010518d:	8d 76 00             	lea    0x0(%esi),%esi

80105190 <sys_unlink>:
{
80105190:	f3 0f 1e fb          	endbr32 
80105194:	55                   	push   %ebp
80105195:	89 e5                	mov    %esp,%ebp
80105197:	57                   	push   %edi
80105198:	56                   	push   %esi
  if(argstr(0, &path) < 0)
80105199:	8d 45 c0             	lea    -0x40(%ebp),%eax
{
8010519c:	53                   	push   %ebx
8010519d:	83 ec 54             	sub    $0x54,%esp
  if(argstr(0, &path) < 0)
801051a0:	50                   	push   %eax
801051a1:	6a 00                	push   $0x0
801051a3:	e8 08 fa ff ff       	call   80104bb0 <argstr>
801051a8:	83 c4 10             	add    $0x10,%esp
801051ab:	85 c0                	test   %eax,%eax
801051ad:	0f 88 7d 01 00 00    	js     80105330 <sys_unlink+0x1a0>
  begin_op();
801051b3:	e8 48 dd ff ff       	call   80102f00 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801051b8:	8d 5d ca             	lea    -0x36(%ebp),%ebx
801051bb:	83 ec 08             	sub    $0x8,%esp
801051be:	53                   	push   %ebx
801051bf:	ff 75 c0             	pushl  -0x40(%ebp)
801051c2:	e8 69 d0 ff ff       	call   80102230 <nameiparent>
801051c7:	83 c4 10             	add    $0x10,%esp
801051ca:	89 c6                	mov    %eax,%esi
801051cc:	85 c0                	test   %eax,%eax
801051ce:	0f 84 66 01 00 00    	je     8010533a <sys_unlink+0x1aa>
  ilock(dp);
801051d4:	83 ec 0c             	sub    $0xc,%esp
801051d7:	50                   	push   %eax
801051d8:	e8 63 c7 ff ff       	call   80101940 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801051dd:	58                   	pop    %eax
801051de:	5a                   	pop    %edx
801051df:	68 7c 81 10 80       	push   $0x8010817c
801051e4:	53                   	push   %ebx
801051e5:	e8 86 cc ff ff       	call   80101e70 <namecmp>
801051ea:	83 c4 10             	add    $0x10,%esp
801051ed:	85 c0                	test   %eax,%eax
801051ef:	0f 84 03 01 00 00    	je     801052f8 <sys_unlink+0x168>
801051f5:	83 ec 08             	sub    $0x8,%esp
801051f8:	68 7b 81 10 80       	push   $0x8010817b
801051fd:	53                   	push   %ebx
801051fe:	e8 6d cc ff ff       	call   80101e70 <namecmp>
80105203:	83 c4 10             	add    $0x10,%esp
80105206:	85 c0                	test   %eax,%eax
80105208:	0f 84 ea 00 00 00    	je     801052f8 <sys_unlink+0x168>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010520e:	83 ec 04             	sub    $0x4,%esp
80105211:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105214:	50                   	push   %eax
80105215:	53                   	push   %ebx
80105216:	56                   	push   %esi
80105217:	e8 74 cc ff ff       	call   80101e90 <dirlookup>
8010521c:	83 c4 10             	add    $0x10,%esp
8010521f:	89 c3                	mov    %eax,%ebx
80105221:	85 c0                	test   %eax,%eax
80105223:	0f 84 cf 00 00 00    	je     801052f8 <sys_unlink+0x168>
  ilock(ip);
80105229:	83 ec 0c             	sub    $0xc,%esp
8010522c:	50                   	push   %eax
8010522d:	e8 0e c7 ff ff       	call   80101940 <ilock>
  if(ip->nlink < 1)
80105232:	83 c4 10             	add    $0x10,%esp
80105235:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010523a:	0f 8e 23 01 00 00    	jle    80105363 <sys_unlink+0x1d3>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105240:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105245:	8d 7d d8             	lea    -0x28(%ebp),%edi
80105248:	74 66                	je     801052b0 <sys_unlink+0x120>
  memset(&de, 0, sizeof(de));
8010524a:	83 ec 04             	sub    $0x4,%esp
8010524d:	6a 10                	push   $0x10
8010524f:	6a 00                	push   $0x0
80105251:	57                   	push   %edi
80105252:	e8 c9 f5 ff ff       	call   80104820 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105257:	6a 10                	push   $0x10
80105259:	ff 75 c4             	pushl  -0x3c(%ebp)
8010525c:	57                   	push   %edi
8010525d:	56                   	push   %esi
8010525e:	e8 dd ca ff ff       	call   80101d40 <writei>
80105263:	83 c4 20             	add    $0x20,%esp
80105266:	83 f8 10             	cmp    $0x10,%eax
80105269:	0f 85 e7 00 00 00    	jne    80105356 <sys_unlink+0x1c6>
  if(ip->type == T_DIR){
8010526f:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105274:	0f 84 96 00 00 00    	je     80105310 <sys_unlink+0x180>
  iunlockput(dp);
8010527a:	83 ec 0c             	sub    $0xc,%esp
8010527d:	56                   	push   %esi
8010527e:	e8 5d c9 ff ff       	call   80101be0 <iunlockput>
  ip->nlink--;
80105283:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
80105288:	89 1c 24             	mov    %ebx,(%esp)
8010528b:	e8 f0 c5 ff ff       	call   80101880 <iupdate>
  iunlockput(ip);
80105290:	89 1c 24             	mov    %ebx,(%esp)
80105293:	e8 48 c9 ff ff       	call   80101be0 <iunlockput>
  end_op();
80105298:	e8 d3 dc ff ff       	call   80102f70 <end_op>
  return 0;
8010529d:	83 c4 10             	add    $0x10,%esp
801052a0:	31 c0                	xor    %eax,%eax
}
801052a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801052a5:	5b                   	pop    %ebx
801052a6:	5e                   	pop    %esi
801052a7:	5f                   	pop    %edi
801052a8:	5d                   	pop    %ebp
801052a9:	c3                   	ret    
801052aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801052b0:	83 7b 58 20          	cmpl   $0x20,0x58(%ebx)
801052b4:	76 94                	jbe    8010524a <sys_unlink+0xba>
801052b6:	ba 20 00 00 00       	mov    $0x20,%edx
801052bb:	eb 0b                	jmp    801052c8 <sys_unlink+0x138>
801052bd:	8d 76 00             	lea    0x0(%esi),%esi
801052c0:	83 c2 10             	add    $0x10,%edx
801052c3:	39 53 58             	cmp    %edx,0x58(%ebx)
801052c6:	76 82                	jbe    8010524a <sys_unlink+0xba>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801052c8:	6a 10                	push   $0x10
801052ca:	52                   	push   %edx
801052cb:	57                   	push   %edi
801052cc:	53                   	push   %ebx
801052cd:	89 55 b4             	mov    %edx,-0x4c(%ebp)
801052d0:	e8 6b c9 ff ff       	call   80101c40 <readi>
801052d5:	83 c4 10             	add    $0x10,%esp
801052d8:	8b 55 b4             	mov    -0x4c(%ebp),%edx
801052db:	83 f8 10             	cmp    $0x10,%eax
801052de:	75 69                	jne    80105349 <sys_unlink+0x1b9>
    if(de.inum != 0)
801052e0:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
801052e5:	74 d9                	je     801052c0 <sys_unlink+0x130>
    iunlockput(ip);
801052e7:	83 ec 0c             	sub    $0xc,%esp
801052ea:	53                   	push   %ebx
801052eb:	e8 f0 c8 ff ff       	call   80101be0 <iunlockput>
    goto bad;
801052f0:	83 c4 10             	add    $0x10,%esp
801052f3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801052f7:	90                   	nop
  iunlockput(dp);
801052f8:	83 ec 0c             	sub    $0xc,%esp
801052fb:	56                   	push   %esi
801052fc:	e8 df c8 ff ff       	call   80101be0 <iunlockput>
  end_op();
80105301:	e8 6a dc ff ff       	call   80102f70 <end_op>
  return -1;
80105306:	83 c4 10             	add    $0x10,%esp
80105309:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010530e:	eb 92                	jmp    801052a2 <sys_unlink+0x112>
    iupdate(dp);
80105310:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink--;
80105313:	66 83 6e 56 01       	subw   $0x1,0x56(%esi)
    iupdate(dp);
80105318:	56                   	push   %esi
80105319:	e8 62 c5 ff ff       	call   80101880 <iupdate>
8010531e:	83 c4 10             	add    $0x10,%esp
80105321:	e9 54 ff ff ff       	jmp    8010527a <sys_unlink+0xea>
80105326:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010532d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105330:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105335:	e9 68 ff ff ff       	jmp    801052a2 <sys_unlink+0x112>
    end_op();
8010533a:	e8 31 dc ff ff       	call   80102f70 <end_op>
    return -1;
8010533f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105344:	e9 59 ff ff ff       	jmp    801052a2 <sys_unlink+0x112>
      panic("isdirempty: readi");
80105349:	83 ec 0c             	sub    $0xc,%esp
8010534c:	68 a0 81 10 80       	push   $0x801081a0
80105351:	e8 2a b1 ff ff       	call   80100480 <panic>
    panic("unlink: writei");
80105356:	83 ec 0c             	sub    $0xc,%esp
80105359:	68 b2 81 10 80       	push   $0x801081b2
8010535e:	e8 1d b1 ff ff       	call   80100480 <panic>
    panic("unlink: nlink < 1");
80105363:	83 ec 0c             	sub    $0xc,%esp
80105366:	68 8e 81 10 80       	push   $0x8010818e
8010536b:	e8 10 b1 ff ff       	call   80100480 <panic>

80105370 <sys_open>:

int
sys_open(void)
{
80105370:	f3 0f 1e fb          	endbr32 
80105374:	55                   	push   %ebp
80105375:	89 e5                	mov    %esp,%ebp
80105377:	57                   	push   %edi
80105378:	56                   	push   %esi
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105379:	8d 45 e0             	lea    -0x20(%ebp),%eax
{
8010537c:	53                   	push   %ebx
8010537d:	83 ec 24             	sub    $0x24,%esp
  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105380:	50                   	push   %eax
80105381:	6a 00                	push   $0x0
80105383:	e8 28 f8 ff ff       	call   80104bb0 <argstr>
80105388:	83 c4 10             	add    $0x10,%esp
8010538b:	85 c0                	test   %eax,%eax
8010538d:	0f 88 8a 00 00 00    	js     8010541d <sys_open+0xad>
80105393:	83 ec 08             	sub    $0x8,%esp
80105396:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105399:	50                   	push   %eax
8010539a:	6a 01                	push   $0x1
8010539c:	e8 5f f7 ff ff       	call   80104b00 <argint>
801053a1:	83 c4 10             	add    $0x10,%esp
801053a4:	85 c0                	test   %eax,%eax
801053a6:	78 75                	js     8010541d <sys_open+0xad>
    return -1;

  begin_op();
801053a8:	e8 53 db ff ff       	call   80102f00 <begin_op>

  if(omode & O_CREATE){
801053ad:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
801053b1:	75 75                	jne    80105428 <sys_open+0xb8>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
801053b3:	83 ec 0c             	sub    $0xc,%esp
801053b6:	ff 75 e0             	pushl  -0x20(%ebp)
801053b9:	e8 52 ce ff ff       	call   80102210 <namei>
801053be:	83 c4 10             	add    $0x10,%esp
801053c1:	89 c6                	mov    %eax,%esi
801053c3:	85 c0                	test   %eax,%eax
801053c5:	74 7e                	je     80105445 <sys_open+0xd5>
      end_op();
      return -1;
    }
    ilock(ip);
801053c7:	83 ec 0c             	sub    $0xc,%esp
801053ca:	50                   	push   %eax
801053cb:	e8 70 c5 ff ff       	call   80101940 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801053d0:	83 c4 10             	add    $0x10,%esp
801053d3:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801053d8:	0f 84 c2 00 00 00    	je     801054a0 <sys_open+0x130>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801053de:	e8 0d bb ff ff       	call   80100ef0 <filealloc>
801053e3:	89 c7                	mov    %eax,%edi
801053e5:	85 c0                	test   %eax,%eax
801053e7:	74 23                	je     8010540c <sys_open+0x9c>
  struct proc *curproc = myproc();
801053e9:	e8 52 e7 ff ff       	call   80103b40 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
801053ee:	31 db                	xor    %ebx,%ebx
    if(curproc->ofile[fd] == 0){
801053f0:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
801053f4:	85 d2                	test   %edx,%edx
801053f6:	74 60                	je     80105458 <sys_open+0xe8>
  for(fd = 0; fd < NOFILE; fd++){
801053f8:	83 c3 01             	add    $0x1,%ebx
801053fb:	83 fb 10             	cmp    $0x10,%ebx
801053fe:	75 f0                	jne    801053f0 <sys_open+0x80>
    if(f)
      fileclose(f);
80105400:	83 ec 0c             	sub    $0xc,%esp
80105403:	57                   	push   %edi
80105404:	e8 a7 bb ff ff       	call   80100fb0 <fileclose>
80105409:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010540c:	83 ec 0c             	sub    $0xc,%esp
8010540f:	56                   	push   %esi
80105410:	e8 cb c7 ff ff       	call   80101be0 <iunlockput>
    end_op();
80105415:	e8 56 db ff ff       	call   80102f70 <end_op>
    return -1;
8010541a:	83 c4 10             	add    $0x10,%esp
8010541d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105422:	eb 6d                	jmp    80105491 <sys_open+0x121>
80105424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    ip = create(path, T_FILE, 0, 0);
80105428:	83 ec 0c             	sub    $0xc,%esp
8010542b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010542e:	31 c9                	xor    %ecx,%ecx
80105430:	ba 02 00 00 00       	mov    $0x2,%edx
80105435:	6a 00                	push   $0x0
80105437:	e8 24 f8 ff ff       	call   80104c60 <create>
    if(ip == 0){
8010543c:	83 c4 10             	add    $0x10,%esp
    ip = create(path, T_FILE, 0, 0);
8010543f:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80105441:	85 c0                	test   %eax,%eax
80105443:	75 99                	jne    801053de <sys_open+0x6e>
      end_op();
80105445:	e8 26 db ff ff       	call   80102f70 <end_op>
      return -1;
8010544a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010544f:	eb 40                	jmp    80105491 <sys_open+0x121>
80105451:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  }
  iunlock(ip);
80105458:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
8010545b:	89 7c 98 28          	mov    %edi,0x28(%eax,%ebx,4)
  iunlock(ip);
8010545f:	56                   	push   %esi
80105460:	e8 bb c5 ff ff       	call   80101a20 <iunlock>
  end_op();
80105465:	e8 06 db ff ff       	call   80102f70 <end_op>

  f->type = FD_INODE;
8010546a:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
80105470:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105473:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
80105476:	89 77 10             	mov    %esi,0x10(%edi)
  f->readable = !(omode & O_WRONLY);
80105479:	89 d0                	mov    %edx,%eax
  f->off = 0;
8010547b:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
80105482:	f7 d0                	not    %eax
80105484:	83 e0 01             	and    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105487:	83 e2 03             	and    $0x3,%edx
  f->readable = !(omode & O_WRONLY);
8010548a:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010548d:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
}
80105491:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105494:	89 d8                	mov    %ebx,%eax
80105496:	5b                   	pop    %ebx
80105497:	5e                   	pop    %esi
80105498:	5f                   	pop    %edi
80105499:	5d                   	pop    %ebp
8010549a:	c3                   	ret    
8010549b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010549f:	90                   	nop
    if(ip->type == T_DIR && omode != O_RDONLY){
801054a0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801054a3:	85 c9                	test   %ecx,%ecx
801054a5:	0f 84 33 ff ff ff    	je     801053de <sys_open+0x6e>
801054ab:	e9 5c ff ff ff       	jmp    8010540c <sys_open+0x9c>

801054b0 <sys_mkdir>:

int
sys_mkdir(void)
{
801054b0:	f3 0f 1e fb          	endbr32 
801054b4:	55                   	push   %ebp
801054b5:	89 e5                	mov    %esp,%ebp
801054b7:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801054ba:	e8 41 da ff ff       	call   80102f00 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801054bf:	83 ec 08             	sub    $0x8,%esp
801054c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054c5:	50                   	push   %eax
801054c6:	6a 00                	push   $0x0
801054c8:	e8 e3 f6 ff ff       	call   80104bb0 <argstr>
801054cd:	83 c4 10             	add    $0x10,%esp
801054d0:	85 c0                	test   %eax,%eax
801054d2:	78 34                	js     80105508 <sys_mkdir+0x58>
801054d4:	83 ec 0c             	sub    $0xc,%esp
801054d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054da:	31 c9                	xor    %ecx,%ecx
801054dc:	ba 01 00 00 00       	mov    $0x1,%edx
801054e1:	6a 00                	push   $0x0
801054e3:	e8 78 f7 ff ff       	call   80104c60 <create>
801054e8:	83 c4 10             	add    $0x10,%esp
801054eb:	85 c0                	test   %eax,%eax
801054ed:	74 19                	je     80105508 <sys_mkdir+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
801054ef:	83 ec 0c             	sub    $0xc,%esp
801054f2:	50                   	push   %eax
801054f3:	e8 e8 c6 ff ff       	call   80101be0 <iunlockput>
  end_op();
801054f8:	e8 73 da ff ff       	call   80102f70 <end_op>
  return 0;
801054fd:	83 c4 10             	add    $0x10,%esp
80105500:	31 c0                	xor    %eax,%eax
}
80105502:	c9                   	leave  
80105503:	c3                   	ret    
80105504:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    end_op();
80105508:	e8 63 da ff ff       	call   80102f70 <end_op>
    return -1;
8010550d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105512:	c9                   	leave  
80105513:	c3                   	ret    
80105514:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010551b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010551f:	90                   	nop

80105520 <sys_mknod>:

int
sys_mknod(void)
{
80105520:	f3 0f 1e fb          	endbr32 
80105524:	55                   	push   %ebp
80105525:	89 e5                	mov    %esp,%ebp
80105527:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010552a:	e8 d1 d9 ff ff       	call   80102f00 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010552f:	83 ec 08             	sub    $0x8,%esp
80105532:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105535:	50                   	push   %eax
80105536:	6a 00                	push   $0x0
80105538:	e8 73 f6 ff ff       	call   80104bb0 <argstr>
8010553d:	83 c4 10             	add    $0x10,%esp
80105540:	85 c0                	test   %eax,%eax
80105542:	78 64                	js     801055a8 <sys_mknod+0x88>
     argint(1, &major) < 0 ||
80105544:	83 ec 08             	sub    $0x8,%esp
80105547:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010554a:	50                   	push   %eax
8010554b:	6a 01                	push   $0x1
8010554d:	e8 ae f5 ff ff       	call   80104b00 <argint>
  if((argstr(0, &path)) < 0 ||
80105552:	83 c4 10             	add    $0x10,%esp
80105555:	85 c0                	test   %eax,%eax
80105557:	78 4f                	js     801055a8 <sys_mknod+0x88>
     argint(2, &minor) < 0 ||
80105559:	83 ec 08             	sub    $0x8,%esp
8010555c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010555f:	50                   	push   %eax
80105560:	6a 02                	push   $0x2
80105562:	e8 99 f5 ff ff       	call   80104b00 <argint>
     argint(1, &major) < 0 ||
80105567:	83 c4 10             	add    $0x10,%esp
8010556a:	85 c0                	test   %eax,%eax
8010556c:	78 3a                	js     801055a8 <sys_mknod+0x88>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010556e:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
80105572:	83 ec 0c             	sub    $0xc,%esp
80105575:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80105579:	ba 03 00 00 00       	mov    $0x3,%edx
8010557e:	50                   	push   %eax
8010557f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105582:	e8 d9 f6 ff ff       	call   80104c60 <create>
     argint(2, &minor) < 0 ||
80105587:	83 c4 10             	add    $0x10,%esp
8010558a:	85 c0                	test   %eax,%eax
8010558c:	74 1a                	je     801055a8 <sys_mknod+0x88>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010558e:	83 ec 0c             	sub    $0xc,%esp
80105591:	50                   	push   %eax
80105592:	e8 49 c6 ff ff       	call   80101be0 <iunlockput>
  end_op();
80105597:	e8 d4 d9 ff ff       	call   80102f70 <end_op>
  return 0;
8010559c:	83 c4 10             	add    $0x10,%esp
8010559f:	31 c0                	xor    %eax,%eax
}
801055a1:	c9                   	leave  
801055a2:	c3                   	ret    
801055a3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801055a7:	90                   	nop
    end_op();
801055a8:	e8 c3 d9 ff ff       	call   80102f70 <end_op>
    return -1;
801055ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055b2:	c9                   	leave  
801055b3:	c3                   	ret    
801055b4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801055bb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801055bf:	90                   	nop

801055c0 <sys_chdir>:

int
sys_chdir(void)
{
801055c0:	f3 0f 1e fb          	endbr32 
801055c4:	55                   	push   %ebp
801055c5:	89 e5                	mov    %esp,%ebp
801055c7:	56                   	push   %esi
801055c8:	53                   	push   %ebx
801055c9:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801055cc:	e8 6f e5 ff ff       	call   80103b40 <myproc>
801055d1:	89 c6                	mov    %eax,%esi

  begin_op();
801055d3:	e8 28 d9 ff ff       	call   80102f00 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801055d8:	83 ec 08             	sub    $0x8,%esp
801055db:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055de:	50                   	push   %eax
801055df:	6a 00                	push   $0x0
801055e1:	e8 ca f5 ff ff       	call   80104bb0 <argstr>
801055e6:	83 c4 10             	add    $0x10,%esp
801055e9:	85 c0                	test   %eax,%eax
801055eb:	78 73                	js     80105660 <sys_chdir+0xa0>
801055ed:	83 ec 0c             	sub    $0xc,%esp
801055f0:	ff 75 f4             	pushl  -0xc(%ebp)
801055f3:	e8 18 cc ff ff       	call   80102210 <namei>
801055f8:	83 c4 10             	add    $0x10,%esp
801055fb:	89 c3                	mov    %eax,%ebx
801055fd:	85 c0                	test   %eax,%eax
801055ff:	74 5f                	je     80105660 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
80105601:	83 ec 0c             	sub    $0xc,%esp
80105604:	50                   	push   %eax
80105605:	e8 36 c3 ff ff       	call   80101940 <ilock>
  if(ip->type != T_DIR){
8010560a:	83 c4 10             	add    $0x10,%esp
8010560d:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105612:	75 2c                	jne    80105640 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105614:	83 ec 0c             	sub    $0xc,%esp
80105617:	53                   	push   %ebx
80105618:	e8 03 c4 ff ff       	call   80101a20 <iunlock>
  iput(curproc->cwd);
8010561d:	58                   	pop    %eax
8010561e:	ff 76 68             	pushl  0x68(%esi)
80105621:	e8 4a c4 ff ff       	call   80101a70 <iput>
  end_op();
80105626:	e8 45 d9 ff ff       	call   80102f70 <end_op>
  curproc->cwd = ip;
8010562b:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
8010562e:	83 c4 10             	add    $0x10,%esp
80105631:	31 c0                	xor    %eax,%eax
}
80105633:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105636:	5b                   	pop    %ebx
80105637:	5e                   	pop    %esi
80105638:	5d                   	pop    %ebp
80105639:	c3                   	ret    
8010563a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(ip);
80105640:	83 ec 0c             	sub    $0xc,%esp
80105643:	53                   	push   %ebx
80105644:	e8 97 c5 ff ff       	call   80101be0 <iunlockput>
    end_op();
80105649:	e8 22 d9 ff ff       	call   80102f70 <end_op>
    return -1;
8010564e:	83 c4 10             	add    $0x10,%esp
80105651:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105656:	eb db                	jmp    80105633 <sys_chdir+0x73>
80105658:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010565f:	90                   	nop
    end_op();
80105660:	e8 0b d9 ff ff       	call   80102f70 <end_op>
    return -1;
80105665:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010566a:	eb c7                	jmp    80105633 <sys_chdir+0x73>
8010566c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105670 <sys_exec>:

int
sys_exec(void)
{
80105670:	f3 0f 1e fb          	endbr32 
80105674:	55                   	push   %ebp
80105675:	89 e5                	mov    %esp,%ebp
80105677:	57                   	push   %edi
80105678:	56                   	push   %esi
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105679:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
{
8010567f:	53                   	push   %ebx
80105680:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105686:	50                   	push   %eax
80105687:	6a 00                	push   $0x0
80105689:	e8 22 f5 ff ff       	call   80104bb0 <argstr>
8010568e:	83 c4 10             	add    $0x10,%esp
80105691:	85 c0                	test   %eax,%eax
80105693:	0f 88 8b 00 00 00    	js     80105724 <sys_exec+0xb4>
80105699:	83 ec 08             	sub    $0x8,%esp
8010569c:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
801056a2:	50                   	push   %eax
801056a3:	6a 01                	push   $0x1
801056a5:	e8 56 f4 ff ff       	call   80104b00 <argint>
801056aa:	83 c4 10             	add    $0x10,%esp
801056ad:	85 c0                	test   %eax,%eax
801056af:	78 73                	js     80105724 <sys_exec+0xb4>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
801056b1:	83 ec 04             	sub    $0x4,%esp
801056b4:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  for(i=0;; i++){
801056ba:	31 db                	xor    %ebx,%ebx
  memset(argv, 0, sizeof(argv));
801056bc:	68 80 00 00 00       	push   $0x80
801056c1:	8d bd 64 ff ff ff    	lea    -0x9c(%ebp),%edi
801056c7:	6a 00                	push   $0x0
801056c9:	50                   	push   %eax
801056ca:	e8 51 f1 ff ff       	call   80104820 <memset>
801056cf:	83 c4 10             	add    $0x10,%esp
801056d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801056d8:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
801056de:	8d 34 9d 00 00 00 00 	lea    0x0(,%ebx,4),%esi
801056e5:	83 ec 08             	sub    $0x8,%esp
801056e8:	57                   	push   %edi
801056e9:	01 f0                	add    %esi,%eax
801056eb:	50                   	push   %eax
801056ec:	e8 6f f3 ff ff       	call   80104a60 <fetchint>
801056f1:	83 c4 10             	add    $0x10,%esp
801056f4:	85 c0                	test   %eax,%eax
801056f6:	78 2c                	js     80105724 <sys_exec+0xb4>
      return -1;
    if(uarg == 0){
801056f8:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
801056fe:	85 c0                	test   %eax,%eax
80105700:	74 36                	je     80105738 <sys_exec+0xc8>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105702:	8d 8d 68 ff ff ff    	lea    -0x98(%ebp),%ecx
80105708:	83 ec 08             	sub    $0x8,%esp
8010570b:	8d 14 31             	lea    (%ecx,%esi,1),%edx
8010570e:	52                   	push   %edx
8010570f:	50                   	push   %eax
80105710:	e8 8b f3 ff ff       	call   80104aa0 <fetchstr>
80105715:	83 c4 10             	add    $0x10,%esp
80105718:	85 c0                	test   %eax,%eax
8010571a:	78 08                	js     80105724 <sys_exec+0xb4>
  for(i=0;; i++){
8010571c:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
8010571f:	83 fb 20             	cmp    $0x20,%ebx
80105722:	75 b4                	jne    801056d8 <sys_exec+0x68>
      return -1;
  }
  return exec(path, argv);
}
80105724:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
80105727:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010572c:	5b                   	pop    %ebx
8010572d:	5e                   	pop    %esi
8010572e:	5f                   	pop    %edi
8010572f:	5d                   	pop    %ebp
80105730:	c3                   	ret    
80105731:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  return exec(path, argv);
80105738:	83 ec 08             	sub    $0x8,%esp
8010573b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
      argv[i] = 0;
80105741:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
80105748:	00 00 00 00 
  return exec(path, argv);
8010574c:	50                   	push   %eax
8010574d:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
80105753:	e8 18 b4 ff ff       	call   80100b70 <exec>
80105758:	83 c4 10             	add    $0x10,%esp
}
8010575b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010575e:	5b                   	pop    %ebx
8010575f:	5e                   	pop    %esi
80105760:	5f                   	pop    %edi
80105761:	5d                   	pop    %ebp
80105762:	c3                   	ret    
80105763:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010576a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105770 <sys_pipe>:

int
sys_pipe(void)
{
80105770:	f3 0f 1e fb          	endbr32 
80105774:	55                   	push   %ebp
80105775:	89 e5                	mov    %esp,%ebp
80105777:	57                   	push   %edi
80105778:	56                   	push   %esi
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105779:	8d 45 dc             	lea    -0x24(%ebp),%eax
{
8010577c:	53                   	push   %ebx
8010577d:	83 ec 20             	sub    $0x20,%esp
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105780:	6a 08                	push   $0x8
80105782:	50                   	push   %eax
80105783:	6a 00                	push   $0x0
80105785:	e8 c6 f3 ff ff       	call   80104b50 <argptr>
8010578a:	83 c4 10             	add    $0x10,%esp
8010578d:	85 c0                	test   %eax,%eax
8010578f:	78 4e                	js     801057df <sys_pipe+0x6f>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80105791:	83 ec 08             	sub    $0x8,%esp
80105794:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105797:	50                   	push   %eax
80105798:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010579b:	50                   	push   %eax
8010579c:	e8 1f de ff ff       	call   801035c0 <pipealloc>
801057a1:	83 c4 10             	add    $0x10,%esp
801057a4:	85 c0                	test   %eax,%eax
801057a6:	78 37                	js     801057df <sys_pipe+0x6f>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801057a8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(fd = 0; fd < NOFILE; fd++){
801057ab:	31 db                	xor    %ebx,%ebx
  struct proc *curproc = myproc();
801057ad:	e8 8e e3 ff ff       	call   80103b40 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
801057b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(curproc->ofile[fd] == 0){
801057b8:	8b 74 98 28          	mov    0x28(%eax,%ebx,4),%esi
801057bc:	85 f6                	test   %esi,%esi
801057be:	74 30                	je     801057f0 <sys_pipe+0x80>
  for(fd = 0; fd < NOFILE; fd++){
801057c0:	83 c3 01             	add    $0x1,%ebx
801057c3:	83 fb 10             	cmp    $0x10,%ebx
801057c6:	75 f0                	jne    801057b8 <sys_pipe+0x48>
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
801057c8:	83 ec 0c             	sub    $0xc,%esp
801057cb:	ff 75 e0             	pushl  -0x20(%ebp)
801057ce:	e8 dd b7 ff ff       	call   80100fb0 <fileclose>
    fileclose(wf);
801057d3:	58                   	pop    %eax
801057d4:	ff 75 e4             	pushl  -0x1c(%ebp)
801057d7:	e8 d4 b7 ff ff       	call   80100fb0 <fileclose>
    return -1;
801057dc:	83 c4 10             	add    $0x10,%esp
801057df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057e4:	eb 5b                	jmp    80105841 <sys_pipe+0xd1>
801057e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801057ed:	8d 76 00             	lea    0x0(%esi),%esi
      curproc->ofile[fd] = f;
801057f0:	8d 73 08             	lea    0x8(%ebx),%esi
801057f3:	89 7c b0 08          	mov    %edi,0x8(%eax,%esi,4)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801057f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  struct proc *curproc = myproc();
801057fa:	e8 41 e3 ff ff       	call   80103b40 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
801057ff:	31 d2                	xor    %edx,%edx
80105801:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[fd] == 0){
80105808:	8b 4c 90 28          	mov    0x28(%eax,%edx,4),%ecx
8010580c:	85 c9                	test   %ecx,%ecx
8010580e:	74 20                	je     80105830 <sys_pipe+0xc0>
  for(fd = 0; fd < NOFILE; fd++){
80105810:	83 c2 01             	add    $0x1,%edx
80105813:	83 fa 10             	cmp    $0x10,%edx
80105816:	75 f0                	jne    80105808 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105818:	e8 23 e3 ff ff       	call   80103b40 <myproc>
8010581d:	c7 44 b0 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,4)
80105824:	00 
80105825:	eb a1                	jmp    801057c8 <sys_pipe+0x58>
80105827:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010582e:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
80105830:	89 7c 90 28          	mov    %edi,0x28(%eax,%edx,4)
  }
  fd[0] = fd0;
80105834:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105837:	89 18                	mov    %ebx,(%eax)
  fd[1] = fd1;
80105839:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010583c:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
8010583f:	31 c0                	xor    %eax,%eax
}
80105841:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105844:	5b                   	pop    %ebx
80105845:	5e                   	pop    %esi
80105846:	5f                   	pop    %edi
80105847:	5d                   	pop    %ebp
80105848:	c3                   	ret    
80105849:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105850 <sys_bstat>:

/* returns the number of swapped pages
 */
int
sys_bstat(void)
{
80105850:	f3 0f 1e fb          	endbr32 
  //************xv7************
	return numallocblocks;
}
80105854:	a1 5c b5 10 80       	mov    0x8010b55c,%eax
80105859:	c3                   	ret    
8010585a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105860 <sys_swap>:
 */

 //*************xv7************
int
sys_swap(void)
{
80105860:	f3 0f 1e fb          	endbr32 
80105864:	55                   	push   %ebp
80105865:	89 e5                	mov    %esp,%ebp
80105867:	57                   	push   %edi
80105868:	56                   	push   %esi
  uint addr;

  if(argint(0, (int*)&addr) < 0)
80105869:	8d 45 e4             	lea    -0x1c(%ebp),%eax
{
8010586c:	53                   	push   %ebx
8010586d:	83 ec 24             	sub    $0x24,%esp
  if(argint(0, (int*)&addr) < 0)
80105870:	50                   	push   %eax
80105871:	6a 00                	push   $0x0
80105873:	e8 88 f2 ff ff       	call   80104b00 <argint>
80105878:	83 c4 10             	add    $0x10,%esp
8010587b:	85 c0                	test   %eax,%eax
8010587d:	0f 88 85 00 00 00    	js     80105908 <sys_swap+0xa8>
    return -1;
  // swap addr
  struct proc *currentProcess=myproc();
80105883:	e8 b8 e2 ff ff       	call   80103b40 <myproc>
  pde_t *pgdir=currentProcess->pgdir;
  pte_t *pte=walkpgdir(pgdir,(char*)addr,1);
80105888:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  pde = &pgdir[PDX(va)];
8010588b:	8b 40 04             	mov    0x4(%eax),%eax
8010588e:	89 f2                	mov    %esi,%edx
80105890:	c1 ea 16             	shr    $0x16,%edx
80105893:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105896:	8b 07                	mov    (%edi),%eax
80105898:	a8 01                	test   $0x1,%al
8010589a:	75 5c                	jne    801058f8 <sys_swap+0x98>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010589c:	e8 5f cf ff ff       	call   80102800 <kalloc>
801058a1:	89 c3                	mov    %eax,%ebx
801058a3:	85 c0                	test   %eax,%eax
801058a5:	0f 84 64 00 00 00    	je     8010590f <sys_swap.cold>
    memset(pgtab, 0, PGSIZE);
801058ab:	83 ec 04             	sub    $0x4,%esp
801058ae:	68 00 10 00 00       	push   $0x1000
801058b3:	6a 00                	push   $0x0
801058b5:	50                   	push   %eax
801058b6:	e8 65 ef ff ff       	call   80104820 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801058bb:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801058c1:	83 c4 10             	add    $0x10,%esp
801058c4:	83 c8 07             	or     $0x7,%eax
801058c7:	89 07                	mov    %eax,(%edi)
  return &pgtab[PTX(va)];
801058c9:	89 f0                	mov    %esi,%eax
801058cb:	c1 e8 0a             	shr    $0xa,%eax
801058ce:	25 fc 0f 00 00       	and    $0xffc,%eax
801058d3:	01 d8                	add    %ebx,%eax
  if(*pte & PTE_P){
    swap_page_from_pte(pte);
  }

  return 0;
801058d5:	31 db                	xor    %ebx,%ebx
  if(*pte & PTE_P){
801058d7:	f6 00 01             	testb  $0x1,(%eax)
801058da:	74 0c                	je     801058e8 <sys_swap+0x88>
    swap_page_from_pte(pte);
801058dc:	83 ec 0c             	sub    $0xc,%esp
801058df:	50                   	push   %eax
801058e0:	e8 0b 06 00 00       	call   80105ef0 <swap_page_from_pte>
801058e5:	83 c4 10             	add    $0x10,%esp
}
801058e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801058eb:	89 d8                	mov    %ebx,%eax
801058ed:	5b                   	pop    %ebx
801058ee:	5e                   	pop    %esi
801058ef:	5f                   	pop    %edi
801058f0:	5d                   	pop    %ebp
801058f1:	c3                   	ret    
801058f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801058f8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801058fd:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80105903:	eb c4                	jmp    801058c9 <sys_swap+0x69>
80105905:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105908:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010590d:	eb d9                	jmp    801058e8 <sys_swap+0x88>

8010590f <sys_swap.cold>:
  if(*pte & PTE_P){
8010590f:	a1 00 00 00 00       	mov    0x0,%eax
80105914:	0f 0b                	ud2    
80105916:	66 90                	xchg   %ax,%ax
80105918:	66 90                	xchg   %ax,%ax
8010591a:	66 90                	xchg   %ax,%ax
8010591c:	66 90                	xchg   %ax,%ax
8010591e:	66 90                	xchg   %ax,%ax

80105920 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105920:	f3 0f 1e fb          	endbr32 
  return fork();
80105924:	e9 97 e3 ff ff       	jmp    80103cc0 <fork>
80105929:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105930 <sys_exit>:
}

int
sys_exit(void)
{
80105930:	f3 0f 1e fb          	endbr32 
80105934:	55                   	push   %ebp
80105935:	89 e5                	mov    %esp,%ebp
80105937:	83 ec 08             	sub    $0x8,%esp
  exit();
8010593a:	e8 01 e6 ff ff       	call   80103f40 <exit>
  return 0;  // not reached
}
8010593f:	31 c0                	xor    %eax,%eax
80105941:	c9                   	leave  
80105942:	c3                   	ret    
80105943:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010594a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105950 <sys_wait>:

int
sys_wait(void)
{
80105950:	f3 0f 1e fb          	endbr32 
  return wait();
80105954:	e9 37 e8 ff ff       	jmp    80104190 <wait>
80105959:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105960 <sys_kill>:
}

int
sys_kill(void)
{
80105960:	f3 0f 1e fb          	endbr32 
80105964:	55                   	push   %ebp
80105965:	89 e5                	mov    %esp,%ebp
80105967:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010596a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010596d:	50                   	push   %eax
8010596e:	6a 00                	push   $0x0
80105970:	e8 8b f1 ff ff       	call   80104b00 <argint>
80105975:	83 c4 10             	add    $0x10,%esp
80105978:	85 c0                	test   %eax,%eax
8010597a:	78 14                	js     80105990 <sys_kill+0x30>
    return -1;
  return kill(pid);
8010597c:	83 ec 0c             	sub    $0xc,%esp
8010597f:	ff 75 f4             	pushl  -0xc(%ebp)
80105982:	e8 89 e9 ff ff       	call   80104310 <kill>
80105987:	83 c4 10             	add    $0x10,%esp
}
8010598a:	c9                   	leave  
8010598b:	c3                   	ret    
8010598c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105990:	c9                   	leave  
    return -1;
80105991:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105996:	c3                   	ret    
80105997:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010599e:	66 90                	xchg   %ax,%ax

801059a0 <sys_getpid>:

int
sys_getpid(void)
{
801059a0:	f3 0f 1e fb          	endbr32 
801059a4:	55                   	push   %ebp
801059a5:	89 e5                	mov    %esp,%ebp
801059a7:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801059aa:	e8 91 e1 ff ff       	call   80103b40 <myproc>
801059af:	8b 40 10             	mov    0x10(%eax),%eax
}
801059b2:	c9                   	leave  
801059b3:	c3                   	ret    
801059b4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801059bb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801059bf:	90                   	nop

801059c0 <sys_sbrk>:

int
sys_sbrk(void)
{
801059c0:	f3 0f 1e fb          	endbr32 
801059c4:	55                   	push   %ebp
801059c5:	89 e5                	mov    %esp,%ebp
801059c7:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
801059c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
801059cb:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
801059ce:	50                   	push   %eax
801059cf:	6a 00                	push   $0x0
801059d1:	e8 2a f1 ff ff       	call   80104b00 <argint>
801059d6:	83 c4 10             	add    $0x10,%esp
801059d9:	85 c0                	test   %eax,%eax
801059db:	78 23                	js     80105a00 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
801059dd:	e8 5e e1 ff ff       	call   80103b40 <myproc>
  if(growproc(n) < 0)
801059e2:	83 ec 0c             	sub    $0xc,%esp
  addr = myproc()->sz;
801059e5:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
801059e7:	ff 75 f4             	pushl  -0xc(%ebp)
801059ea:	e8 81 e2 ff ff       	call   80103c70 <growproc>
801059ef:	83 c4 10             	add    $0x10,%esp
801059f2:	85 c0                	test   %eax,%eax
801059f4:	78 0a                	js     80105a00 <sys_sbrk+0x40>
    return -1;
  return addr;
}
801059f6:	89 d8                	mov    %ebx,%eax
801059f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801059fb:	c9                   	leave  
801059fc:	c3                   	ret    
801059fd:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105a00:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105a05:	eb ef                	jmp    801059f6 <sys_sbrk+0x36>
80105a07:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a0e:	66 90                	xchg   %ax,%ax

80105a10 <sys_sleep>:

int
sys_sleep(void)
{
80105a10:	f3 0f 1e fb          	endbr32 
80105a14:	55                   	push   %ebp
80105a15:	89 e5                	mov    %esp,%ebp
80105a17:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105a18:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105a1b:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105a1e:	50                   	push   %eax
80105a1f:	6a 00                	push   $0x0
80105a21:	e8 da f0 ff ff       	call   80104b00 <argint>
80105a26:	83 c4 10             	add    $0x10,%esp
80105a29:	85 c0                	test   %eax,%eax
80105a2b:	0f 88 86 00 00 00    	js     80105ab7 <sys_sleep+0xa7>
    return -1;
  acquire(&tickslock);
80105a31:	83 ec 0c             	sub    $0xc,%esp
80105a34:	68 c0 7d 11 80       	push   $0x80117dc0
80105a39:	e8 62 ec ff ff       	call   801046a0 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80105a3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ticks0 = ticks;
80105a41:	8b 1d 00 86 11 80    	mov    0x80118600,%ebx
  while(ticks - ticks0 < n){
80105a47:	83 c4 10             	add    $0x10,%esp
80105a4a:	85 d2                	test   %edx,%edx
80105a4c:	75 23                	jne    80105a71 <sys_sleep+0x61>
80105a4e:	eb 50                	jmp    80105aa0 <sys_sleep+0x90>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105a50:	83 ec 08             	sub    $0x8,%esp
80105a53:	68 c0 7d 11 80       	push   $0x80117dc0
80105a58:	68 00 86 11 80       	push   $0x80118600
80105a5d:	e8 6e e6 ff ff       	call   801040d0 <sleep>
  while(ticks - ticks0 < n){
80105a62:	a1 00 86 11 80       	mov    0x80118600,%eax
80105a67:	83 c4 10             	add    $0x10,%esp
80105a6a:	29 d8                	sub    %ebx,%eax
80105a6c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105a6f:	73 2f                	jae    80105aa0 <sys_sleep+0x90>
    if(myproc()->killed){
80105a71:	e8 ca e0 ff ff       	call   80103b40 <myproc>
80105a76:	8b 40 24             	mov    0x24(%eax),%eax
80105a79:	85 c0                	test   %eax,%eax
80105a7b:	74 d3                	je     80105a50 <sys_sleep+0x40>
      release(&tickslock);
80105a7d:	83 ec 0c             	sub    $0xc,%esp
80105a80:	68 c0 7d 11 80       	push   $0x80117dc0
80105a85:	e8 46 ed ff ff       	call   801047d0 <release>
  }
  release(&tickslock);
  return 0;
}
80105a8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return -1;
80105a8d:	83 c4 10             	add    $0x10,%esp
80105a90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a95:	c9                   	leave  
80105a96:	c3                   	ret    
80105a97:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a9e:	66 90                	xchg   %ax,%ax
  release(&tickslock);
80105aa0:	83 ec 0c             	sub    $0xc,%esp
80105aa3:	68 c0 7d 11 80       	push   $0x80117dc0
80105aa8:	e8 23 ed ff ff       	call   801047d0 <release>
  return 0;
80105aad:	83 c4 10             	add    $0x10,%esp
80105ab0:	31 c0                	xor    %eax,%eax
}
80105ab2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105ab5:	c9                   	leave  
80105ab6:	c3                   	ret    
    return -1;
80105ab7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105abc:	eb f4                	jmp    80105ab2 <sys_sleep+0xa2>
80105abe:	66 90                	xchg   %ax,%ax

80105ac0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105ac0:	f3 0f 1e fb          	endbr32 
80105ac4:	55                   	push   %ebp
80105ac5:	89 e5                	mov    %esp,%ebp
80105ac7:	53                   	push   %ebx
80105ac8:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80105acb:	68 c0 7d 11 80       	push   $0x80117dc0
80105ad0:	e8 cb eb ff ff       	call   801046a0 <acquire>
  xticks = ticks;
80105ad5:	8b 1d 00 86 11 80    	mov    0x80118600,%ebx
  release(&tickslock);
80105adb:	c7 04 24 c0 7d 11 80 	movl   $0x80117dc0,(%esp)
80105ae2:	e8 e9 ec ff ff       	call   801047d0 <release>
  return xticks;
}
80105ae7:	89 d8                	mov    %ebx,%eax
80105ae9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105aec:	c9                   	leave  
80105aed:	c3                   	ret    

80105aee <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105aee:	1e                   	push   %ds
  pushl %es
80105aef:	06                   	push   %es
  pushl %fs
80105af0:	0f a0                	push   %fs
  pushl %gs
80105af2:	0f a8                	push   %gs
  pushal
80105af4:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105af5:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105af9:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105afb:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105afd:	54                   	push   %esp
  call trap
80105afe:	e8 cd 00 00 00       	call   80105bd0 <trap>
  addl $4, %esp
80105b03:	83 c4 04             	add    $0x4,%esp

80105b06 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105b06:	61                   	popa   
  popl %gs
80105b07:	0f a9                	pop    %gs
  popl %fs
80105b09:	0f a1                	pop    %fs
  popl %es
80105b0b:	07                   	pop    %es
  popl %ds
80105b0c:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105b0d:	83 c4 08             	add    $0x8,%esp
  iret
80105b10:	cf                   	iret   
80105b11:	66 90                	xchg   %ax,%ax
80105b13:	66 90                	xchg   %ax,%ax
80105b15:	66 90                	xchg   %ax,%ax
80105b17:	66 90                	xchg   %ax,%ax
80105b19:	66 90                	xchg   %ax,%ax
80105b1b:	66 90                	xchg   %ax,%ax
80105b1d:	66 90                	xchg   %ax,%ax
80105b1f:	90                   	nop

80105b20 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105b20:	f3 0f 1e fb          	endbr32 
80105b24:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
80105b25:	31 c0                	xor    %eax,%eax
{
80105b27:	89 e5                	mov    %esp,%ebp
80105b29:	83 ec 08             	sub    $0x8,%esp
80105b2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105b30:	8b 14 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%edx
80105b37:	c7 04 c5 02 7e 11 80 	movl   $0x8e000008,-0x7fee81fe(,%eax,8)
80105b3e:	08 00 00 8e 
80105b42:	66 89 14 c5 00 7e 11 	mov    %dx,-0x7fee8200(,%eax,8)
80105b49:	80 
80105b4a:	c1 ea 10             	shr    $0x10,%edx
80105b4d:	66 89 14 c5 06 7e 11 	mov    %dx,-0x7fee81fa(,%eax,8)
80105b54:	80 
  for(i = 0; i < 256; i++)
80105b55:	83 c0 01             	add    $0x1,%eax
80105b58:	3d 00 01 00 00       	cmp    $0x100,%eax
80105b5d:	75 d1                	jne    80105b30 <tvinit+0x10>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
80105b5f:	83 ec 08             	sub    $0x8,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105b62:	a1 08 b1 10 80       	mov    0x8010b108,%eax
80105b67:	c7 05 02 80 11 80 08 	movl   $0xef000008,0x80118002
80105b6e:	00 00 ef 
  initlock(&tickslock, "time");
80105b71:	68 c1 81 10 80       	push   $0x801081c1
80105b76:	68 c0 7d 11 80       	push   $0x80117dc0
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105b7b:	66 a3 00 80 11 80    	mov    %ax,0x80118000
80105b81:	c1 e8 10             	shr    $0x10,%eax
80105b84:	66 a3 06 80 11 80    	mov    %ax,0x80118006
  initlock(&tickslock, "time");
80105b8a:	e8 01 ea ff ff       	call   80104590 <initlock>
}
80105b8f:	83 c4 10             	add    $0x10,%esp
80105b92:	c9                   	leave  
80105b93:	c3                   	ret    
80105b94:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105b9b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105b9f:	90                   	nop

80105ba0 <idtinit>:

void
idtinit(void)
{
80105ba0:	f3 0f 1e fb          	endbr32 
80105ba4:	55                   	push   %ebp
  pd[0] = size-1;
80105ba5:	b8 ff 07 00 00       	mov    $0x7ff,%eax
80105baa:	89 e5                	mov    %esp,%ebp
80105bac:	83 ec 10             	sub    $0x10,%esp
80105baf:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105bb3:	b8 00 7e 11 80       	mov    $0x80117e00,%eax
80105bb8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105bbc:	c1 e8 10             	shr    $0x10,%eax
80105bbf:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105bc3:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105bc6:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80105bc9:	c9                   	leave  
80105bca:	c3                   	ret    
80105bcb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105bcf:	90                   	nop

80105bd0 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105bd0:	f3 0f 1e fb          	endbr32 
80105bd4:	55                   	push   %ebp
80105bd5:	89 e5                	mov    %esp,%ebp
80105bd7:	57                   	push   %edi
80105bd8:	56                   	push   %esi
80105bd9:	53                   	push   %ebx
80105bda:	83 ec 1c             	sub    $0x1c,%esp
80105bdd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80105be0:	8b 43 30             	mov    0x30(%ebx),%eax
80105be3:	83 f8 40             	cmp    $0x40,%eax
80105be6:	0f 84 d4 01 00 00    	je     80105dc0 <trap+0x1f0>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105bec:	83 e8 0e             	sub    $0xe,%eax
80105bef:	83 f8 31             	cmp    $0x31,%eax
80105bf2:	77 08                	ja     80105bfc <trap+0x2c>
80105bf4:	3e ff 24 85 68 82 10 	notrack jmp *-0x7fef7d98(,%eax,4)
80105bfb:	80 
    lapiceoi();
    break;

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80105bfc:	e8 3f df ff ff       	call   80103b40 <myproc>
80105c01:	8b 7b 38             	mov    0x38(%ebx),%edi
80105c04:	85 c0                	test   %eax,%eax
80105c06:	0f 84 03 02 00 00    	je     80105e0f <trap+0x23f>
80105c0c:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105c10:	0f 84 f9 01 00 00    	je     80105e0f <trap+0x23f>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105c16:	0f 20 d1             	mov    %cr2,%ecx
80105c19:	89 4d d8             	mov    %ecx,-0x28(%ebp)
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105c1c:	e8 ff de ff ff       	call   80103b20 <cpuid>
80105c21:	8b 73 30             	mov    0x30(%ebx),%esi
80105c24:	89 45 dc             	mov    %eax,-0x24(%ebp)
80105c27:	8b 43 34             	mov    0x34(%ebx),%eax
80105c2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80105c2d:	e8 0e df ff ff       	call   80103b40 <myproc>
80105c32:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105c35:	e8 06 df ff ff       	call   80103b40 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105c3a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80105c3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105c40:	8b 40 10             	mov    0x10(%eax),%eax
80105c43:	51                   	push   %ecx
80105c44:	57                   	push   %edi
80105c45:	52                   	push   %edx
80105c46:	ff 75 e4             	pushl  -0x1c(%ebp)
80105c49:	56                   	push   %esi
            myproc()->pid, myproc()->name, tf->trapno,
80105c4a:	8b 75 e0             	mov    -0x20(%ebp),%esi
80105c4d:	83 c6 6c             	add    $0x6c,%esi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105c50:	56                   	push   %esi
80105c51:	50                   	push   %eax
80105c52:	68 24 82 10 80       	push   $0x80108224
80105c57:	e8 44 ab ff ff       	call   801007a0 <cprintf>
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80105c5c:	83 c4 20             	add    $0x20,%esp
80105c5f:	e8 dc de ff ff       	call   80103b40 <myproc>
80105c64:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105c6b:	e8 d0 de ff ff       	call   80103b40 <myproc>
80105c70:	85 c0                	test   %eax,%eax
80105c72:	74 1d                	je     80105c91 <trap+0xc1>
80105c74:	e8 c7 de ff ff       	call   80103b40 <myproc>
80105c79:	8b 50 24             	mov    0x24(%eax),%edx
80105c7c:	85 d2                	test   %edx,%edx
80105c7e:	74 11                	je     80105c91 <trap+0xc1>
80105c80:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105c84:	83 e0 03             	and    $0x3,%eax
80105c87:	66 83 f8 03          	cmp    $0x3,%ax
80105c8b:	0f 84 67 01 00 00    	je     80105df8 <trap+0x228>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105c91:	e8 aa de ff ff       	call   80103b40 <myproc>
80105c96:	85 c0                	test   %eax,%eax
80105c98:	74 0f                	je     80105ca9 <trap+0xd9>
80105c9a:	e8 a1 de ff ff       	call   80103b40 <myproc>
80105c9f:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105ca3:	0f 84 ff 00 00 00    	je     80105da8 <trap+0x1d8>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105ca9:	e8 92 de ff ff       	call   80103b40 <myproc>
80105cae:	85 c0                	test   %eax,%eax
80105cb0:	74 1d                	je     80105ccf <trap+0xff>
80105cb2:	e8 89 de ff ff       	call   80103b40 <myproc>
80105cb7:	8b 40 24             	mov    0x24(%eax),%eax
80105cba:	85 c0                	test   %eax,%eax
80105cbc:	74 11                	je     80105ccf <trap+0xff>
80105cbe:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105cc2:	83 e0 03             	and    $0x3,%eax
80105cc5:	66 83 f8 03          	cmp    $0x3,%ax
80105cc9:	0f 84 1a 01 00 00    	je     80105de9 <trap+0x219>
    exit();
}
80105ccf:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105cd2:	5b                   	pop    %ebx
80105cd3:	5e                   	pop    %esi
80105cd4:	5f                   	pop    %edi
80105cd5:	5d                   	pop    %ebp
80105cd6:	c3                   	ret    
    ideintr();
80105cd7:	e8 d4 c6 ff ff       	call   801023b0 <ideintr>
    lapiceoi();
80105cdc:	e8 af cd ff ff       	call   80102a90 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105ce1:	e8 5a de ff ff       	call   80103b40 <myproc>
80105ce6:	85 c0                	test   %eax,%eax
80105ce8:	75 8a                	jne    80105c74 <trap+0xa4>
80105cea:	eb a5                	jmp    80105c91 <trap+0xc1>
  	handle_pgfault();
80105cec:	e8 8f 04 00 00       	call   80106180 <handle_pgfault>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105cf1:	e8 4a de ff ff       	call   80103b40 <myproc>
80105cf6:	85 c0                	test   %eax,%eax
80105cf8:	0f 85 76 ff ff ff    	jne    80105c74 <trap+0xa4>
80105cfe:	eb 91                	jmp    80105c91 <trap+0xc1>
    if(cpuid() == 0){
80105d00:	e8 1b de ff ff       	call   80103b20 <cpuid>
80105d05:	85 c0                	test   %eax,%eax
80105d07:	75 d3                	jne    80105cdc <trap+0x10c>
      acquire(&tickslock);
80105d09:	83 ec 0c             	sub    $0xc,%esp
80105d0c:	68 c0 7d 11 80       	push   $0x80117dc0
80105d11:	e8 8a e9 ff ff       	call   801046a0 <acquire>
      wakeup(&ticks);
80105d16:	c7 04 24 00 86 11 80 	movl   $0x80118600,(%esp)
      ticks++;
80105d1d:	83 05 00 86 11 80 01 	addl   $0x1,0x80118600
      wakeup(&ticks);
80105d24:	e8 77 e5 ff ff       	call   801042a0 <wakeup>
      release(&tickslock);
80105d29:	c7 04 24 c0 7d 11 80 	movl   $0x80117dc0,(%esp)
80105d30:	e8 9b ea ff ff       	call   801047d0 <release>
80105d35:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80105d38:	eb a2                	jmp    80105cdc <trap+0x10c>
    kbdintr();
80105d3a:	e8 11 cc ff ff       	call   80102950 <kbdintr>
    lapiceoi();
80105d3f:	e8 4c cd ff ff       	call   80102a90 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105d44:	e8 f7 dd ff ff       	call   80103b40 <myproc>
80105d49:	85 c0                	test   %eax,%eax
80105d4b:	0f 85 23 ff ff ff    	jne    80105c74 <trap+0xa4>
80105d51:	e9 3b ff ff ff       	jmp    80105c91 <trap+0xc1>
    uartintr();
80105d56:	e8 95 06 00 00       	call   801063f0 <uartintr>
    lapiceoi();
80105d5b:	e8 30 cd ff ff       	call   80102a90 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105d60:	e8 db dd ff ff       	call   80103b40 <myproc>
80105d65:	85 c0                	test   %eax,%eax
80105d67:	0f 85 07 ff ff ff    	jne    80105c74 <trap+0xa4>
80105d6d:	e9 1f ff ff ff       	jmp    80105c91 <trap+0xc1>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105d72:	8b 7b 38             	mov    0x38(%ebx),%edi
80105d75:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
80105d79:	e8 a2 dd ff ff       	call   80103b20 <cpuid>
80105d7e:	57                   	push   %edi
80105d7f:	56                   	push   %esi
80105d80:	50                   	push   %eax
80105d81:	68 cc 81 10 80       	push   $0x801081cc
80105d86:	e8 15 aa ff ff       	call   801007a0 <cprintf>
    lapiceoi();
80105d8b:	e8 00 cd ff ff       	call   80102a90 <lapiceoi>
    break;
80105d90:	83 c4 10             	add    $0x10,%esp
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105d93:	e8 a8 dd ff ff       	call   80103b40 <myproc>
80105d98:	85 c0                	test   %eax,%eax
80105d9a:	0f 85 d4 fe ff ff    	jne    80105c74 <trap+0xa4>
80105da0:	e9 ec fe ff ff       	jmp    80105c91 <trap+0xc1>
80105da5:	8d 76 00             	lea    0x0(%esi),%esi
  if(myproc() && myproc()->state == RUNNING &&
80105da8:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105dac:	0f 85 f7 fe ff ff    	jne    80105ca9 <trap+0xd9>
    yield();
80105db2:	e8 c9 e2 ff ff       	call   80104080 <yield>
80105db7:	e9 ed fe ff ff       	jmp    80105ca9 <trap+0xd9>
80105dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed)
80105dc0:	e8 7b dd ff ff       	call   80103b40 <myproc>
80105dc5:	8b 70 24             	mov    0x24(%eax),%esi
80105dc8:	85 f6                	test   %esi,%esi
80105dca:	75 3c                	jne    80105e08 <trap+0x238>
    myproc()->tf = tf;
80105dcc:	e8 6f dd ff ff       	call   80103b40 <myproc>
80105dd1:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80105dd4:	e8 17 ee ff ff       	call   80104bf0 <syscall>
    if(myproc()->killed)
80105dd9:	e8 62 dd ff ff       	call   80103b40 <myproc>
80105dde:	8b 48 24             	mov    0x24(%eax),%ecx
80105de1:	85 c9                	test   %ecx,%ecx
80105de3:	0f 84 e6 fe ff ff    	je     80105ccf <trap+0xff>
}
80105de9:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105dec:	5b                   	pop    %ebx
80105ded:	5e                   	pop    %esi
80105dee:	5f                   	pop    %edi
80105def:	5d                   	pop    %ebp
      exit();
80105df0:	e9 4b e1 ff ff       	jmp    80103f40 <exit>
80105df5:	8d 76 00             	lea    0x0(%esi),%esi
    exit();
80105df8:	e8 43 e1 ff ff       	call   80103f40 <exit>
80105dfd:	e9 8f fe ff ff       	jmp    80105c91 <trap+0xc1>
80105e02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      exit();
80105e08:	e8 33 e1 ff ff       	call   80103f40 <exit>
80105e0d:	eb bd                	jmp    80105dcc <trap+0x1fc>
80105e0f:	0f 20 d6             	mov    %cr2,%esi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105e12:	e8 09 dd ff ff       	call   80103b20 <cpuid>
80105e17:	83 ec 0c             	sub    $0xc,%esp
80105e1a:	56                   	push   %esi
80105e1b:	57                   	push   %edi
80105e1c:	50                   	push   %eax
80105e1d:	ff 73 30             	pushl  0x30(%ebx)
80105e20:	68 f0 81 10 80       	push   $0x801081f0
80105e25:	e8 76 a9 ff ff       	call   801007a0 <cprintf>
      panic("trap");
80105e2a:	83 c4 14             	add    $0x14,%esp
80105e2d:	68 c6 81 10 80       	push   $0x801081c6
80105e32:	e8 49 a6 ff ff       	call   80100480 <panic>
80105e37:	66 90                	xchg   %ax,%ax
80105e39:	66 90                	xchg   %ax,%ax
80105e3b:	66 90                	xchg   %ax,%ax
80105e3d:	66 90                	xchg   %ax,%ax
80105e3f:	90                   	nop

80105e40 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105e40:	55                   	push   %ebp
80105e41:	89 e5                	mov    %esp,%ebp
80105e43:	57                   	push   %edi
80105e44:	56                   	push   %esi
80105e45:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105e47:	c1 ea 16             	shr    $0x16,%edx
{
80105e4a:	53                   	push   %ebx
  pde = &pgdir[PDX(va)];
80105e4b:	8d 3c 90             	lea    (%eax,%edx,4),%edi
{
80105e4e:	83 ec 0c             	sub    $0xc,%esp
  if(*pde & PTE_P){
80105e51:	8b 1f                	mov    (%edi),%ebx
80105e53:	f6 c3 01             	test   $0x1,%bl
80105e56:	74 28                	je     80105e80 <walkpgdir+0x40>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105e58:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105e5e:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105e64:	89 f0                	mov    %esi,%eax
}
80105e66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return &pgtab[PTX(va)];
80105e69:	c1 e8 0a             	shr    $0xa,%eax
80105e6c:	25 fc 0f 00 00       	and    $0xffc,%eax
80105e71:	01 d8                	add    %ebx,%eax
}
80105e73:	5b                   	pop    %ebx
80105e74:	5e                   	pop    %esi
80105e75:	5f                   	pop    %edi
80105e76:	5d                   	pop    %ebp
80105e77:	c3                   	ret    
80105e78:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105e7f:	90                   	nop
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105e80:	85 c9                	test   %ecx,%ecx
80105e82:	74 2c                	je     80105eb0 <walkpgdir+0x70>
80105e84:	e8 77 c9 ff ff       	call   80102800 <kalloc>
80105e89:	89 c3                	mov    %eax,%ebx
80105e8b:	85 c0                	test   %eax,%eax
80105e8d:	74 21                	je     80105eb0 <walkpgdir+0x70>
    memset(pgtab, 0, PGSIZE);
80105e8f:	83 ec 04             	sub    $0x4,%esp
80105e92:	68 00 10 00 00       	push   $0x1000
80105e97:	6a 00                	push   $0x0
80105e99:	50                   	push   %eax
80105e9a:	e8 81 e9 ff ff       	call   80104820 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105e9f:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105ea5:	83 c4 10             	add    $0x10,%esp
80105ea8:	83 c8 07             	or     $0x7,%eax
80105eab:	89 07                	mov    %eax,(%edi)
80105ead:	eb b5                	jmp    80105e64 <walkpgdir+0x24>
80105eaf:	90                   	nop
}
80105eb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return 0;
80105eb3:	31 c0                	xor    %eax,%eax
}
80105eb5:	5b                   	pop    %ebx
80105eb6:	5e                   	pop    %esi
80105eb7:	5f                   	pop    %edi
80105eb8:	5d                   	pop    %ebp
80105eb9:	c3                   	ret    
80105eba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105ec0 <myprocXV7>:
myprocXV7(void) {
80105ec0:	f3 0f 1e fb          	endbr32 
80105ec4:	55                   	push   %ebp
80105ec5:	89 e5                	mov    %esp,%ebp
80105ec7:	53                   	push   %ebx
80105ec8:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80105ecb:	e8 80 e7 ff ff       	call   80104650 <pushcli>
  c = mycpu();
80105ed0:	e8 db db ff ff       	call   80103ab0 <mycpu>
  p = c->proc;
80105ed5:	8b 98 b8 00 00 00    	mov    0xb8(%eax),%ebx
  popcli();
80105edb:	e8 90 e8 ff ff       	call   80104770 <popcli>
}
80105ee0:	83 c4 04             	add    $0x4,%esp
80105ee3:	89 d8                	mov    %ebx,%eax
80105ee5:	5b                   	pop    %ebx
80105ee6:	5d                   	pop    %ebp
80105ee7:	c3                   	ret    
80105ee8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105eef:	90                   	nop

80105ef0 <swap_page_from_pte>:
{
80105ef0:	f3 0f 1e fb          	endbr32 
80105ef4:	55                   	push   %ebp
80105ef5:	89 e5                	mov    %esp,%ebp
80105ef7:	57                   	push   %edi
80105ef8:	56                   	push   %esi
80105ef9:	53                   	push   %ebx
80105efa:	83 ec 0c             	sub    $0xc,%esp
80105efd:	8b 7d 08             	mov    0x8(%ebp),%edi
  if(physicalAddress==0)  // mosh fahm da lazmoth eh
80105f00:	8b 37                	mov    (%edi),%esi
80105f02:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
80105f08:	74 46                	je     80105f50 <swap_page_from_pte+0x60>
  uint diskPage=balloc_page(ROOTDEV);   // hna barg3 awl mkan fe disk ynf3 an2l feh page
80105f0a:	83 ec 0c             	sub    $0xc,%esp
  write_page_to_disk(ROOTDEV,(char*)P2V(physicalAddress),diskPage);    //write this page to disk  // hna bktb fe disk elpage ally ana 3awzha
80105f0d:	81 c6 00 00 00 80    	add    $0x80000000,%esi
  uint diskPage=balloc_page(ROOTDEV);   // hna barg3 awl mkan fe disk ynf3 an2l feh page
80105f13:	6a 01                	push   $0x1
80105f15:	e8 26 b7 ff ff       	call   80101640 <balloc_page>
  write_page_to_disk(ROOTDEV,(char*)P2V(physicalAddress),diskPage);    //write this page to disk  // hna bktb fe disk elpage ally ana 3awzha
80105f1a:	83 c4 0c             	add    $0xc,%esp
80105f1d:	50                   	push   %eax
  uint diskPage=balloc_page(ROOTDEV);   // hna barg3 awl mkan fe disk ynf3 an2l feh page
80105f1e:	89 c3                	mov    %eax,%ebx
  write_page_to_disk(ROOTDEV,(char*)P2V(physicalAddress),diskPage);    //write this page to disk  // hna bktb fe disk elpage ally ana 3awzha
80105f20:	56                   	push   %esi
  *pte = (diskPage << 12)| PTE_SWAPPED;
80105f21:	c1 e3 0c             	shl    $0xc,%ebx
  write_page_to_disk(ROOTDEV,(char*)P2V(physicalAddress),diskPage);    //write this page to disk  // hna bktb fe disk elpage ally ana 3awzha
80105f24:	6a 01                	push   $0x1
  *pte = (diskPage << 12)| PTE_SWAPPED;
80105f26:	80 cf 02             	or     $0x2,%bh
  write_page_to_disk(ROOTDEV,(char*)P2V(physicalAddress),diskPage);    //write this page to disk  // hna bktb fe disk elpage ally ana 3awzha
80105f29:	e8 82 a3 ff ff       	call   801002b0 <write_page_to_disk>
  *pte = (diskPage << 12)| PTE_SWAPPED;
80105f2e:	89 1f                	mov    %ebx,(%edi)
  kfree(P2V(physicalAddress));
80105f30:	89 34 24             	mov    %esi,(%esp)
80105f33:	e8 08 c7 ff ff       	call   80102640 <kfree>
  cprintf("\nReturning from swap page from pte\n");
80105f38:	c7 45 08 54 83 10 80 	movl   $0x80108354,0x8(%ebp)
80105f3f:	83 c4 10             	add    $0x10,%esp
}
80105f42:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105f45:	5b                   	pop    %ebx
80105f46:	5e                   	pop    %esi
80105f47:	5f                   	pop    %edi
80105f48:	5d                   	pop    %ebp
  cprintf("\nReturning from swap page from pte\n");
80105f49:	e9 52 a8 ff ff       	jmp    801007a0 <cprintf>
80105f4e:	66 90                	xchg   %ax,%ax
    cprintf("physicalAddress address is zero\n");
80105f50:	83 ec 0c             	sub    $0xc,%esp
80105f53:	68 30 83 10 80       	push   $0x80108330
80105f58:	e8 43 a8 ff ff       	call   801007a0 <cprintf>
80105f5d:	83 c4 10             	add    $0x10,%esp
80105f60:	eb a8                	jmp    80105f0a <swap_page_from_pte+0x1a>
80105f62:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105f70 <swap_page>:
{
80105f70:	f3 0f 1e fb          	endbr32 
80105f74:	55                   	push   %ebp
80105f75:	89 e5                	mov    %esp,%ebp
80105f77:	56                   	push   %esi
80105f78:	53                   	push   %ebx
80105f79:	8b 75 08             	mov    0x8(%ebp),%esi
  pte_t* pte=select_a_victim(pgdir);         //returns *pte  (page table fady ynf3 ast5dmoh
80105f7c:	83 ec 0c             	sub    $0xc,%esp
80105f7f:	56                   	push   %esi
80105f80:	e8 4b 16 00 00       	call   801075d0 <select_a_victim>
  if(pte==0){                                     //If this is true, victim is not found in 1st attempt. Inside this function
80105f85:	83 c4 10             	add    $0x10,%esp
80105f88:	85 c0                	test   %eax,%eax
80105f8a:	74 34                	je     80105fc0 <swap_page+0x50>
    cprintf("Victim found in 1st attempt.");
80105f8c:	83 ec 0c             	sub    $0xc,%esp
80105f8f:	89 c3                	mov    %eax,%ebx
80105f91:	68 4a 84 10 80       	push   $0x8010844a
80105f96:	e8 05 a8 ff ff       	call   801007a0 <cprintf>
80105f9b:	83 c4 10             	add    $0x10,%esp
  swap_page_from_pte(pte);  //swap victim page to disk
80105f9e:	83 ec 0c             	sub    $0xc,%esp
  lcr3(V2P(pgdir));         //This operation ensures that the older TLB entries are flushed
80105fa1:	81 c6 00 00 00 80    	add    $0x80000000,%esi
  swap_page_from_pte(pte);  //swap victim page to disk
80105fa7:	53                   	push   %ebx
80105fa8:	e8 43 ff ff ff       	call   80105ef0 <swap_page_from_pte>
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105fad:	0f 22 de             	mov    %esi,%cr3
}
80105fb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105fb3:	b8 01 00 00 00       	mov    $0x1,%eax
80105fb8:	5b                   	pop    %ebx
80105fb9:	5e                   	pop    %esi
80105fba:	5d                   	pop    %ebp
80105fbb:	c3                   	ret    
80105fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    cprintf("No victim found in 1st attempt. Clearing access bits.");
80105fc0:	83 ec 0c             	sub    $0xc,%esp
80105fc3:	68 78 83 10 80       	push   $0x80108378
80105fc8:	e8 d3 a7 ff ff       	call   801007a0 <cprintf>
    else clearaccessbit_FIFO(pgdir);             // student edit
80105fcd:	89 34 24             	mov    %esi,(%esp)
80105fd0:	e8 8b 16 00 00       	call   80107660 <clearaccessbit_FIFO>
    cprintf("Finding victim again, after clearing access bits of 10%% pages.");
80105fd5:	c7 04 24 b0 83 10 80 	movl   $0x801083b0,(%esp)
80105fdc:	e8 bf a7 ff ff       	call   801007a0 <cprintf>
    pte=select_a_victim(pgdir);                   //then victim is selected again. Victim is found this time.
80105fe1:	89 34 24             	mov    %esi,(%esp)
80105fe4:	e8 e7 15 00 00       	call   801075d0 <select_a_victim>
    if(pte!=0) cprintf("victim found");
80105fe9:	83 c4 10             	add    $0x10,%esp
    pte=select_a_victim(pgdir);                   //then victim is selected again. Victim is found this time.
80105fec:	89 c3                	mov    %eax,%ebx
    if(pte!=0) cprintf("victim found");
80105fee:	85 c0                	test   %eax,%eax
80105ff0:	74 16                	je     80106008 <swap_page+0x98>
80105ff2:	83 ec 0c             	sub    $0xc,%esp
80105ff5:	68 3d 84 10 80       	push   $0x8010843d
80105ffa:	e8 a1 a7 ff ff       	call   801007a0 <cprintf>
80105fff:	83 c4 10             	add    $0x10,%esp
80106002:	eb 9a                	jmp    80105f9e <swap_page+0x2e>
80106004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    else cprintf("Not found even in second attempt." );
80106008:	83 ec 0c             	sub    $0xc,%esp
8010600b:	68 f0 83 10 80       	push   $0x801083f0
80106010:	e8 8b a7 ff ff       	call   801007a0 <cprintf>
80106015:	83 c4 10             	add    $0x10,%esp
80106018:	eb 84                	jmp    80105f9e <swap_page+0x2e>
8010601a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106020 <map_address>:
{
80106020:	f3 0f 1e fb          	endbr32 
80106024:	55                   	push   %ebp
80106025:	89 e5                	mov    %esp,%ebp
80106027:	57                   	push   %edi
80106028:	56                   	push   %esi
80106029:	53                   	push   %ebx
8010602a:	83 ec 1c             	sub    $0x1c,%esp
8010602d:	8b 7d 08             	mov    0x8(%ebp),%edi
  pushcli();
80106030:	e8 1b e6 ff ff       	call   80104650 <pushcli>
  c = mycpu();
80106035:	e8 76 da ff ff       	call   80103ab0 <mycpu>
  popcli();
8010603a:	e8 31 e7 ff ff       	call   80104770 <popcli>
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010603f:	0f 20 d2             	mov    %cr2,%edx
  pte_t *pte=walkpgdir(pgdir, (char*)a, 0);
80106042:	31 c9                	xor    %ecx,%ecx
	uint a= PGROUNDDOWN(rcr2());			//rounds the address to a multiple of page size (PGSIZE)
80106044:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  pte_t *pte=walkpgdir(pgdir, (char*)a, 0);
8010604a:	89 f8                	mov    %edi,%eax
8010604c:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010604f:	89 d6                	mov    %edx,%esi
80106051:	e8 ea fd ff ff       	call   80105e40 <walkpgdir>
80106056:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	char *mem=kalloc();    //allocate a physical page
80106059:	e8 a2 c7 ff ff       	call   80102800 <kalloc>
  if(mem==0){
8010605e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80106061:	8b 55 e0             	mov    -0x20(%ebp),%edx
80106064:	85 c0                	test   %eax,%eax
80106066:	89 c3                	mov    %eax,%ebx
80106068:	0f 84 e2 00 00 00    	je     80106150 <map_address+0x130>
  if(pte!=0){
8010606e:	85 c9                	test   %ecx,%ecx
80106070:	0f 84 d2 00 00 00    	je     80106148 <map_address+0x128>
    if(*pte & PTE_SWAPPED){
80106076:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010607c:	f7 01 00 02 00 00    	testl  $0x200,(%ecx)
80106082:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80106085:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106088:	75 5e                	jne    801060e8 <map_address+0xc8>
      memset(mem,0,PGSIZE);
8010608a:	83 ec 04             	sub    $0x4,%esp
8010608d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80106090:	68 00 10 00 00       	push   $0x1000
80106095:	6a 00                	push   $0x0
80106097:	53                   	push   %ebx
80106098:	e8 83 e7 ff ff       	call   80104820 <memset>
{
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010609d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801060a0:	83 c4 10             	add    $0x10,%esp
801060a3:	29 d3                	sub    %edx,%ebx
801060a5:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801060ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
801060ae:	eb 10                	jmp    801060c0 <map_address+0xa0>
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    // if(*pte & PTE_P)
    //   panic("remap in mappages in paging.c");
    *pte = pa | perm | PTE_P;
801060b0:	83 cb 07             	or     $0x7,%ebx
801060b3:	89 18                	mov    %ebx,(%eax)
    if(a == last)
801060b5:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
801060b8:	74 76                	je     80106130 <map_address+0x110>
      break;
    a += PGSIZE;
801060ba:	81 c6 00 10 00 00    	add    $0x1000,%esi
  for(;;){
801060c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801060c3:	b9 01 00 00 00       	mov    $0x1,%ecx
801060c8:	89 f2                	mov    %esi,%edx
801060ca:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
801060cd:	89 f8                	mov    %edi,%eax
801060cf:	e8 6c fd ff ff       	call   80105e40 <walkpgdir>
801060d4:	85 c0                	test   %eax,%eax
801060d6:	75 d8                	jne    801060b0 <map_address+0x90>
    		panic("allocuvm out of memory xv7 in mappages/n");
801060d8:	83 ec 0c             	sub    $0xc,%esp
801060db:	68 14 84 10 80       	push   $0x80108414
801060e0:	e8 9b a3 ff ff       	call   80100480 <panic>
801060e5:	8d 76 00             	lea    0x0(%esi),%esi
      blockid=getswappedblk(pgdir,a);      //disk id where the page was swapped
801060e8:	83 ec 08             	sub    $0x8,%esp
801060eb:	52                   	push   %edx
801060ec:	57                   	push   %edi
      lcr3(V2P(pgdir));
801060ed:	81 c7 00 00 00 80    	add    $0x80000000,%edi
      blockid=getswappedblk(pgdir,a);      //disk id where the page was swapped
801060f3:	e8 38 16 00 00       	call   80107730 <getswappedblk>
      read_page_from_disk(ROOTDEV, mem, blockid);
801060f8:	83 c4 0c             	add    $0xc,%esp
801060fb:	50                   	push   %eax
      blockid=getswappedblk(pgdir,a);      //disk id where the page was swapped
801060fc:	89 c6                	mov    %eax,%esi
      read_page_from_disk(ROOTDEV, mem, blockid);
801060fe:	53                   	push   %ebx
801060ff:	6a 01                	push   $0x1
80106101:	e8 1a a2 ff ff       	call   80100320 <read_page_from_disk>
      *pte &= ~PTE_SWAPPED;
80106106:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106109:	8b 4d e0             	mov    -0x20(%ebp),%ecx
8010610c:	80 e6 fd             	and    $0xfd,%dh
8010610f:	83 ca 07             	or     $0x7,%edx
80106112:	89 11                	mov    %edx,(%ecx)
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106114:	0f 22 df             	mov    %edi,%cr3
      bfree_page(ROOTDEV,blockid);
80106117:	89 75 0c             	mov    %esi,0xc(%ebp)
8010611a:	83 c4 10             	add    $0x10,%esp
8010611d:	c7 45 08 01 00 00 00 	movl   $0x1,0x8(%ebp)
}
80106124:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106127:	5b                   	pop    %ebx
80106128:	5e                   	pop    %esi
80106129:	5f                   	pop    %edi
8010612a:	5d                   	pop    %ebp
      bfree_page(ROOTDEV,blockid);
8010612b:	e9 c0 b5 ff ff       	jmp    801016f0 <bfree_page>
    		cprintf("mappages working");
80106130:	c7 45 08 77 84 10 80 	movl   $0x80108477,0x8(%ebp)
}
80106137:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010613a:	5b                   	pop    %ebx
8010613b:	5e                   	pop    %esi
8010613c:	5f                   	pop    %edi
8010613d:	5d                   	pop    %ebp
    		cprintf("mappages working");
8010613e:	e9 5d a6 ff ff       	jmp    801007a0 <cprintf>
80106143:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80106147:	90                   	nop
}
80106148:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010614b:	5b                   	pop    %ebx
8010614c:	5e                   	pop    %esi
8010614d:	5f                   	pop    %edi
8010614e:	5d                   	pop    %ebp
8010614f:	c3                   	ret    
    swap_page(pgdir);
80106150:	83 ec 0c             	sub    $0xc,%esp
80106153:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80106156:	57                   	push   %edi
80106157:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010615a:	e8 11 fe ff ff       	call   80105f70 <swap_page>
    mem=kalloc();             //now a physical page has been swapped to disk and free, so this time we will get physical page for sure.
8010615f:	e8 9c c6 ff ff       	call   80102800 <kalloc>
    cprintf("kalloc success\n");
80106164:	c7 04 24 67 84 10 80 	movl   $0x80108467,(%esp)
    mem=kalloc();             //now a physical page has been swapped to disk and free, so this time we will get physical page for sure.
8010616b:	89 c3                	mov    %eax,%ebx
    cprintf("kalloc success\n");
8010616d:	e8 2e a6 ff ff       	call   801007a0 <cprintf>
80106172:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80106175:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106178:	83 c4 10             	add    $0x10,%esp
8010617b:	e9 ee fe ff ff       	jmp    8010606e <map_address+0x4e>

80106180 <handle_pgfault>:
{
80106180:	f3 0f 1e fb          	endbr32 
80106184:	55                   	push   %ebp
80106185:	89 e5                	mov    %esp,%ebp
80106187:	53                   	push   %ebx
80106188:	83 ec 04             	sub    $0x4,%esp
  pushcli();
8010618b:	e8 c0 e4 ff ff       	call   80104650 <pushcli>
  c = mycpu();
80106190:	e8 1b d9 ff ff       	call   80103ab0 <mycpu>
  p = c->proc;
80106195:	8b 98 b8 00 00 00    	mov    0xb8(%eax),%ebx
  popcli();
8010619b:	e8 d0 e5 ff ff       	call   80104770 <popcli>
	asm volatile ("movl %%cr2, %0 \n\t" : "=r" (addr));
801061a0:	0f 20 d0             	mov    %cr2,%eax
	map_address(curproc->pgdir, addr);
801061a3:	83 ec 08             	sub    $0x8,%esp
	addr &= ~0xfff;
801061a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	map_address(curproc->pgdir, addr);
801061ab:	50                   	push   %eax
801061ac:	ff 73 04             	pushl  0x4(%ebx)
801061af:	e8 6c fe ff ff       	call   80106020 <map_address>
	updatePageCount (curproc);                 // student edit
801061b4:	89 1c 24             	mov    %ebx,(%esp)
801061b7:	e8 c4 14 00 00       	call   80107680 <updatePageCount>
}
801061bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801061bf:	83 c4 10             	add    $0x10,%esp
801061c2:	c9                   	leave  
801061c3:	c3                   	ret    
801061c4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801061cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801061cf:	90                   	nop

801061d0 <deallocuvmXV7>:
{
801061d0:	f3 0f 1e fb          	endbr32 
801061d4:	55                   	push   %ebp
801061d5:	89 e5                	mov    %esp,%ebp
801061d7:	57                   	push   %edi
801061d8:	56                   	push   %esi
801061d9:	53                   	push   %ebx
801061da:	83 ec 0c             	sub    $0xc,%esp
801061dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801061e0:	8b 75 08             	mov    0x8(%ebp),%esi
    return oldsz;
801061e3:	89 d8                	mov    %ebx,%eax
  if(newsz >= oldsz)
801061e5:	39 5d 10             	cmp    %ebx,0x10(%ebp)
801061e8:	73 6c                	jae    80106256 <deallocuvmXV7+0x86>
  a = PGROUNDUP(newsz);
801061ea:	8b 45 10             	mov    0x10(%ebp),%eax
801061ed:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801061f3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
801061f9:	89 d7                	mov    %edx,%edi
  for(; a  < oldsz; a += PGSIZE){
801061fb:	39 d3                	cmp    %edx,%ebx
801061fd:	76 54                	jbe    80106253 <deallocuvmXV7+0x83>
801061ff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80106202:	eb 0f                	jmp    80106213 <deallocuvmXV7+0x43>
80106204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80106208:	81 c7 00 10 00 00    	add    $0x1000,%edi
8010620e:	39 7d 0c             	cmp    %edi,0xc(%ebp)
80106211:	76 40                	jbe    80106253 <deallocuvmXV7+0x83>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106213:	31 c9                	xor    %ecx,%ecx
80106215:	89 fa                	mov    %edi,%edx
80106217:	89 f0                	mov    %esi,%eax
80106219:	e8 22 fc ff ff       	call   80105e40 <walkpgdir>
8010621e:	89 c3                	mov    %eax,%ebx
    if(!pte)
80106220:	85 c0                	test   %eax,%eax
80106222:	74 3c                	je     80106260 <deallocuvmXV7+0x90>
    else if((*pte & PTE_P) != 0){
80106224:	8b 00                	mov    (%eax),%eax
80106226:	a8 01                	test   $0x1,%al
80106228:	74 de                	je     80106208 <deallocuvmXV7+0x38>
      if(pa == 0)
8010622a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010622f:	74 3f                	je     80106270 <deallocuvmXV7+0xa0>
      kfree(v);
80106231:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
80106234:	05 00 00 00 80       	add    $0x80000000,%eax
80106239:	81 c7 00 10 00 00    	add    $0x1000,%edi
      kfree(v);
8010623f:	50                   	push   %eax
80106240:	e8 fb c3 ff ff       	call   80102640 <kfree>
      *pte = 0;
80106245:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
8010624b:	83 c4 10             	add    $0x10,%esp
  for(; a  < oldsz; a += PGSIZE){
8010624e:	39 7d 0c             	cmp    %edi,0xc(%ebp)
80106251:	77 c0                	ja     80106213 <deallocuvmXV7+0x43>
  return newsz;
80106253:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106256:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106259:	5b                   	pop    %ebx
8010625a:	5e                   	pop    %esi
8010625b:	5f                   	pop    %edi
8010625c:	5d                   	pop    %ebp
8010625d:	c3                   	ret    
8010625e:	66 90                	xchg   %ax,%ax
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106260:	89 fa                	mov    %edi,%edx
80106262:	81 e2 00 00 c0 ff    	and    $0xffc00000,%edx
80106268:	8d ba 00 00 40 00    	lea    0x400000(%edx),%edi
8010626e:	eb 9e                	jmp    8010620e <deallocuvmXV7+0x3e>
        panic("kfree");
80106270:	83 ec 0c             	sub    $0xc,%esp
80106273:	68 88 84 10 80       	push   $0x80108488
80106278:	e8 03 a2 ff ff       	call   80100480 <panic>
8010627d:	66 90                	xchg   %ax,%ax
8010627f:	90                   	nop

80106280 <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
80106280:	f3 0f 1e fb          	endbr32 
  if(!uart)
80106284:	a1 bc b5 10 80       	mov    0x8010b5bc,%eax
80106289:	85 c0                	test   %eax,%eax
8010628b:	74 1b                	je     801062a8 <uartgetc+0x28>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010628d:	ba fd 03 00 00       	mov    $0x3fd,%edx
80106292:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80106293:	a8 01                	test   $0x1,%al
80106295:	74 11                	je     801062a8 <uartgetc+0x28>
80106297:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010629c:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
8010629d:	0f b6 c0             	movzbl %al,%eax
801062a0:	c3                   	ret    
801062a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
801062a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801062ad:	c3                   	ret    
801062ae:	66 90                	xchg   %ax,%ax

801062b0 <uartputc.part.0>:
uartputc(int c)
801062b0:	55                   	push   %ebp
801062b1:	89 e5                	mov    %esp,%ebp
801062b3:	57                   	push   %edi
801062b4:	89 c7                	mov    %eax,%edi
801062b6:	56                   	push   %esi
801062b7:	be fd 03 00 00       	mov    $0x3fd,%esi
801062bc:	53                   	push   %ebx
801062bd:	bb 80 00 00 00       	mov    $0x80,%ebx
801062c2:	83 ec 0c             	sub    $0xc,%esp
801062c5:	eb 1b                	jmp    801062e2 <uartputc.part.0+0x32>
801062c7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801062ce:	66 90                	xchg   %ax,%ax
    microdelay(10);
801062d0:	83 ec 0c             	sub    $0xc,%esp
801062d3:	6a 0a                	push   $0xa
801062d5:	e8 d6 c7 ff ff       	call   80102ab0 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801062da:	83 c4 10             	add    $0x10,%esp
801062dd:	83 eb 01             	sub    $0x1,%ebx
801062e0:	74 07                	je     801062e9 <uartputc.part.0+0x39>
801062e2:	89 f2                	mov    %esi,%edx
801062e4:	ec                   	in     (%dx),%al
801062e5:	a8 20                	test   $0x20,%al
801062e7:	74 e7                	je     801062d0 <uartputc.part.0+0x20>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801062e9:	ba f8 03 00 00       	mov    $0x3f8,%edx
801062ee:	89 f8                	mov    %edi,%eax
801062f0:	ee                   	out    %al,(%dx)
}
801062f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062f4:	5b                   	pop    %ebx
801062f5:	5e                   	pop    %esi
801062f6:	5f                   	pop    %edi
801062f7:	5d                   	pop    %ebp
801062f8:	c3                   	ret    
801062f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106300 <uartinit>:
{
80106300:	f3 0f 1e fb          	endbr32 
80106304:	55                   	push   %ebp
80106305:	31 c9                	xor    %ecx,%ecx
80106307:	89 c8                	mov    %ecx,%eax
80106309:	89 e5                	mov    %esp,%ebp
8010630b:	57                   	push   %edi
8010630c:	56                   	push   %esi
8010630d:	53                   	push   %ebx
8010630e:	bb fa 03 00 00       	mov    $0x3fa,%ebx
80106313:	89 da                	mov    %ebx,%edx
80106315:	83 ec 0c             	sub    $0xc,%esp
80106318:	ee                   	out    %al,(%dx)
80106319:	bf fb 03 00 00       	mov    $0x3fb,%edi
8010631e:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80106323:	89 fa                	mov    %edi,%edx
80106325:	ee                   	out    %al,(%dx)
80106326:	b8 0c 00 00 00       	mov    $0xc,%eax
8010632b:	ba f8 03 00 00       	mov    $0x3f8,%edx
80106330:	ee                   	out    %al,(%dx)
80106331:	be f9 03 00 00       	mov    $0x3f9,%esi
80106336:	89 c8                	mov    %ecx,%eax
80106338:	89 f2                	mov    %esi,%edx
8010633a:	ee                   	out    %al,(%dx)
8010633b:	b8 03 00 00 00       	mov    $0x3,%eax
80106340:	89 fa                	mov    %edi,%edx
80106342:	ee                   	out    %al,(%dx)
80106343:	ba fc 03 00 00       	mov    $0x3fc,%edx
80106348:	89 c8                	mov    %ecx,%eax
8010634a:	ee                   	out    %al,(%dx)
8010634b:	b8 01 00 00 00       	mov    $0x1,%eax
80106350:	89 f2                	mov    %esi,%edx
80106352:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106353:	ba fd 03 00 00       	mov    $0x3fd,%edx
80106358:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80106359:	3c ff                	cmp    $0xff,%al
8010635b:	74 52                	je     801063af <uartinit+0xaf>
  uart = 1;
8010635d:	c7 05 bc b5 10 80 01 	movl   $0x1,0x8010b5bc
80106364:	00 00 00 
80106367:	89 da                	mov    %ebx,%edx
80106369:	ec                   	in     (%dx),%al
8010636a:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010636f:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80106370:	83 ec 08             	sub    $0x8,%esp
80106373:	be 76 00 00 00       	mov    $0x76,%esi
  for(p="xv6...\n"; *p; p++)
80106378:	bb 8e 84 10 80       	mov    $0x8010848e,%ebx
  ioapicenable(IRQ_COM1, 0);
8010637d:	6a 00                	push   $0x0
8010637f:	6a 04                	push   $0x4
80106381:	e8 7a c2 ff ff       	call   80102600 <ioapicenable>
80106386:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106389:	b8 78 00 00 00       	mov    $0x78,%eax
8010638e:	eb 04                	jmp    80106394 <uartinit+0x94>
80106390:	0f b6 73 01          	movzbl 0x1(%ebx),%esi
  if(!uart)
80106394:	8b 15 bc b5 10 80    	mov    0x8010b5bc,%edx
8010639a:	85 d2                	test   %edx,%edx
8010639c:	74 08                	je     801063a6 <uartinit+0xa6>
    uartputc(*p);
8010639e:	0f be c0             	movsbl %al,%eax
801063a1:	e8 0a ff ff ff       	call   801062b0 <uartputc.part.0>
  for(p="xv6...\n"; *p; p++)
801063a6:	89 f0                	mov    %esi,%eax
801063a8:	83 c3 01             	add    $0x1,%ebx
801063ab:	84 c0                	test   %al,%al
801063ad:	75 e1                	jne    80106390 <uartinit+0x90>
}
801063af:	8d 65 f4             	lea    -0xc(%ebp),%esp
801063b2:	5b                   	pop    %ebx
801063b3:	5e                   	pop    %esi
801063b4:	5f                   	pop    %edi
801063b5:	5d                   	pop    %ebp
801063b6:	c3                   	ret    
801063b7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801063be:	66 90                	xchg   %ax,%ax

801063c0 <uartputc>:
{
801063c0:	f3 0f 1e fb          	endbr32 
801063c4:	55                   	push   %ebp
  if(!uart)
801063c5:	8b 15 bc b5 10 80    	mov    0x8010b5bc,%edx
{
801063cb:	89 e5                	mov    %esp,%ebp
801063cd:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!uart)
801063d0:	85 d2                	test   %edx,%edx
801063d2:	74 0c                	je     801063e0 <uartputc+0x20>
}
801063d4:	5d                   	pop    %ebp
801063d5:	e9 d6 fe ff ff       	jmp    801062b0 <uartputc.part.0>
801063da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801063e0:	5d                   	pop    %ebp
801063e1:	c3                   	ret    
801063e2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801063e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801063f0 <uartintr>:

void
uartintr(void)
{
801063f0:	f3 0f 1e fb          	endbr32 
801063f4:	55                   	push   %ebp
801063f5:	89 e5                	mov    %esp,%ebp
801063f7:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801063fa:	68 80 62 10 80       	push   $0x80106280
801063ff:	e8 4c a5 ff ff       	call   80100950 <consoleintr>
}
80106404:	83 c4 10             	add    $0x10,%esp
80106407:	c9                   	leave  
80106408:	c3                   	ret    

80106409 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106409:	6a 00                	push   $0x0
  pushl $0
8010640b:	6a 00                	push   $0x0
  jmp alltraps
8010640d:	e9 dc f6 ff ff       	jmp    80105aee <alltraps>

80106412 <vector1>:
.globl vector1
vector1:
  pushl $0
80106412:	6a 00                	push   $0x0
  pushl $1
80106414:	6a 01                	push   $0x1
  jmp alltraps
80106416:	e9 d3 f6 ff ff       	jmp    80105aee <alltraps>

8010641b <vector2>:
.globl vector2
vector2:
  pushl $0
8010641b:	6a 00                	push   $0x0
  pushl $2
8010641d:	6a 02                	push   $0x2
  jmp alltraps
8010641f:	e9 ca f6 ff ff       	jmp    80105aee <alltraps>

80106424 <vector3>:
.globl vector3
vector3:
  pushl $0
80106424:	6a 00                	push   $0x0
  pushl $3
80106426:	6a 03                	push   $0x3
  jmp alltraps
80106428:	e9 c1 f6 ff ff       	jmp    80105aee <alltraps>

8010642d <vector4>:
.globl vector4
vector4:
  pushl $0
8010642d:	6a 00                	push   $0x0
  pushl $4
8010642f:	6a 04                	push   $0x4
  jmp alltraps
80106431:	e9 b8 f6 ff ff       	jmp    80105aee <alltraps>

80106436 <vector5>:
.globl vector5
vector5:
  pushl $0
80106436:	6a 00                	push   $0x0
  pushl $5
80106438:	6a 05                	push   $0x5
  jmp alltraps
8010643a:	e9 af f6 ff ff       	jmp    80105aee <alltraps>

8010643f <vector6>:
.globl vector6
vector6:
  pushl $0
8010643f:	6a 00                	push   $0x0
  pushl $6
80106441:	6a 06                	push   $0x6
  jmp alltraps
80106443:	e9 a6 f6 ff ff       	jmp    80105aee <alltraps>

80106448 <vector7>:
.globl vector7
vector7:
  pushl $0
80106448:	6a 00                	push   $0x0
  pushl $7
8010644a:	6a 07                	push   $0x7
  jmp alltraps
8010644c:	e9 9d f6 ff ff       	jmp    80105aee <alltraps>

80106451 <vector8>:
.globl vector8
vector8:
  pushl $8
80106451:	6a 08                	push   $0x8
  jmp alltraps
80106453:	e9 96 f6 ff ff       	jmp    80105aee <alltraps>

80106458 <vector9>:
.globl vector9
vector9:
  pushl $0
80106458:	6a 00                	push   $0x0
  pushl $9
8010645a:	6a 09                	push   $0x9
  jmp alltraps
8010645c:	e9 8d f6 ff ff       	jmp    80105aee <alltraps>

80106461 <vector10>:
.globl vector10
vector10:
  pushl $10
80106461:	6a 0a                	push   $0xa
  jmp alltraps
80106463:	e9 86 f6 ff ff       	jmp    80105aee <alltraps>

80106468 <vector11>:
.globl vector11
vector11:
  pushl $11
80106468:	6a 0b                	push   $0xb
  jmp alltraps
8010646a:	e9 7f f6 ff ff       	jmp    80105aee <alltraps>

8010646f <vector12>:
.globl vector12
vector12:
  pushl $12
8010646f:	6a 0c                	push   $0xc
  jmp alltraps
80106471:	e9 78 f6 ff ff       	jmp    80105aee <alltraps>

80106476 <vector13>:
.globl vector13
vector13:
  pushl $13
80106476:	6a 0d                	push   $0xd
  jmp alltraps
80106478:	e9 71 f6 ff ff       	jmp    80105aee <alltraps>

8010647d <vector14>:
.globl vector14
vector14:
  pushl $14
8010647d:	6a 0e                	push   $0xe
  jmp alltraps
8010647f:	e9 6a f6 ff ff       	jmp    80105aee <alltraps>

80106484 <vector15>:
.globl vector15
vector15:
  pushl $0
80106484:	6a 00                	push   $0x0
  pushl $15
80106486:	6a 0f                	push   $0xf
  jmp alltraps
80106488:	e9 61 f6 ff ff       	jmp    80105aee <alltraps>

8010648d <vector16>:
.globl vector16
vector16:
  pushl $0
8010648d:	6a 00                	push   $0x0
  pushl $16
8010648f:	6a 10                	push   $0x10
  jmp alltraps
80106491:	e9 58 f6 ff ff       	jmp    80105aee <alltraps>

80106496 <vector17>:
.globl vector17
vector17:
  pushl $17
80106496:	6a 11                	push   $0x11
  jmp alltraps
80106498:	e9 51 f6 ff ff       	jmp    80105aee <alltraps>

8010649d <vector18>:
.globl vector18
vector18:
  pushl $0
8010649d:	6a 00                	push   $0x0
  pushl $18
8010649f:	6a 12                	push   $0x12
  jmp alltraps
801064a1:	e9 48 f6 ff ff       	jmp    80105aee <alltraps>

801064a6 <vector19>:
.globl vector19
vector19:
  pushl $0
801064a6:	6a 00                	push   $0x0
  pushl $19
801064a8:	6a 13                	push   $0x13
  jmp alltraps
801064aa:	e9 3f f6 ff ff       	jmp    80105aee <alltraps>

801064af <vector20>:
.globl vector20
vector20:
  pushl $0
801064af:	6a 00                	push   $0x0
  pushl $20
801064b1:	6a 14                	push   $0x14
  jmp alltraps
801064b3:	e9 36 f6 ff ff       	jmp    80105aee <alltraps>

801064b8 <vector21>:
.globl vector21
vector21:
  pushl $0
801064b8:	6a 00                	push   $0x0
  pushl $21
801064ba:	6a 15                	push   $0x15
  jmp alltraps
801064bc:	e9 2d f6 ff ff       	jmp    80105aee <alltraps>

801064c1 <vector22>:
.globl vector22
vector22:
  pushl $0
801064c1:	6a 00                	push   $0x0
  pushl $22
801064c3:	6a 16                	push   $0x16
  jmp alltraps
801064c5:	e9 24 f6 ff ff       	jmp    80105aee <alltraps>

801064ca <vector23>:
.globl vector23
vector23:
  pushl $0
801064ca:	6a 00                	push   $0x0
  pushl $23
801064cc:	6a 17                	push   $0x17
  jmp alltraps
801064ce:	e9 1b f6 ff ff       	jmp    80105aee <alltraps>

801064d3 <vector24>:
.globl vector24
vector24:
  pushl $0
801064d3:	6a 00                	push   $0x0
  pushl $24
801064d5:	6a 18                	push   $0x18
  jmp alltraps
801064d7:	e9 12 f6 ff ff       	jmp    80105aee <alltraps>

801064dc <vector25>:
.globl vector25
vector25:
  pushl $0
801064dc:	6a 00                	push   $0x0
  pushl $25
801064de:	6a 19                	push   $0x19
  jmp alltraps
801064e0:	e9 09 f6 ff ff       	jmp    80105aee <alltraps>

801064e5 <vector26>:
.globl vector26
vector26:
  pushl $0
801064e5:	6a 00                	push   $0x0
  pushl $26
801064e7:	6a 1a                	push   $0x1a
  jmp alltraps
801064e9:	e9 00 f6 ff ff       	jmp    80105aee <alltraps>

801064ee <vector27>:
.globl vector27
vector27:
  pushl $0
801064ee:	6a 00                	push   $0x0
  pushl $27
801064f0:	6a 1b                	push   $0x1b
  jmp alltraps
801064f2:	e9 f7 f5 ff ff       	jmp    80105aee <alltraps>

801064f7 <vector28>:
.globl vector28
vector28:
  pushl $0
801064f7:	6a 00                	push   $0x0
  pushl $28
801064f9:	6a 1c                	push   $0x1c
  jmp alltraps
801064fb:	e9 ee f5 ff ff       	jmp    80105aee <alltraps>

80106500 <vector29>:
.globl vector29
vector29:
  pushl $0
80106500:	6a 00                	push   $0x0
  pushl $29
80106502:	6a 1d                	push   $0x1d
  jmp alltraps
80106504:	e9 e5 f5 ff ff       	jmp    80105aee <alltraps>

80106509 <vector30>:
.globl vector30
vector30:
  pushl $0
80106509:	6a 00                	push   $0x0
  pushl $30
8010650b:	6a 1e                	push   $0x1e
  jmp alltraps
8010650d:	e9 dc f5 ff ff       	jmp    80105aee <alltraps>

80106512 <vector31>:
.globl vector31
vector31:
  pushl $0
80106512:	6a 00                	push   $0x0
  pushl $31
80106514:	6a 1f                	push   $0x1f
  jmp alltraps
80106516:	e9 d3 f5 ff ff       	jmp    80105aee <alltraps>

8010651b <vector32>:
.globl vector32
vector32:
  pushl $0
8010651b:	6a 00                	push   $0x0
  pushl $32
8010651d:	6a 20                	push   $0x20
  jmp alltraps
8010651f:	e9 ca f5 ff ff       	jmp    80105aee <alltraps>

80106524 <vector33>:
.globl vector33
vector33:
  pushl $0
80106524:	6a 00                	push   $0x0
  pushl $33
80106526:	6a 21                	push   $0x21
  jmp alltraps
80106528:	e9 c1 f5 ff ff       	jmp    80105aee <alltraps>

8010652d <vector34>:
.globl vector34
vector34:
  pushl $0
8010652d:	6a 00                	push   $0x0
  pushl $34
8010652f:	6a 22                	push   $0x22
  jmp alltraps
80106531:	e9 b8 f5 ff ff       	jmp    80105aee <alltraps>

80106536 <vector35>:
.globl vector35
vector35:
  pushl $0
80106536:	6a 00                	push   $0x0
  pushl $35
80106538:	6a 23                	push   $0x23
  jmp alltraps
8010653a:	e9 af f5 ff ff       	jmp    80105aee <alltraps>

8010653f <vector36>:
.globl vector36
vector36:
  pushl $0
8010653f:	6a 00                	push   $0x0
  pushl $36
80106541:	6a 24                	push   $0x24
  jmp alltraps
80106543:	e9 a6 f5 ff ff       	jmp    80105aee <alltraps>

80106548 <vector37>:
.globl vector37
vector37:
  pushl $0
80106548:	6a 00                	push   $0x0
  pushl $37
8010654a:	6a 25                	push   $0x25
  jmp alltraps
8010654c:	e9 9d f5 ff ff       	jmp    80105aee <alltraps>

80106551 <vector38>:
.globl vector38
vector38:
  pushl $0
80106551:	6a 00                	push   $0x0
  pushl $38
80106553:	6a 26                	push   $0x26
  jmp alltraps
80106555:	e9 94 f5 ff ff       	jmp    80105aee <alltraps>

8010655a <vector39>:
.globl vector39
vector39:
  pushl $0
8010655a:	6a 00                	push   $0x0
  pushl $39
8010655c:	6a 27                	push   $0x27
  jmp alltraps
8010655e:	e9 8b f5 ff ff       	jmp    80105aee <alltraps>

80106563 <vector40>:
.globl vector40
vector40:
  pushl $0
80106563:	6a 00                	push   $0x0
  pushl $40
80106565:	6a 28                	push   $0x28
  jmp alltraps
80106567:	e9 82 f5 ff ff       	jmp    80105aee <alltraps>

8010656c <vector41>:
.globl vector41
vector41:
  pushl $0
8010656c:	6a 00                	push   $0x0
  pushl $41
8010656e:	6a 29                	push   $0x29
  jmp alltraps
80106570:	e9 79 f5 ff ff       	jmp    80105aee <alltraps>

80106575 <vector42>:
.globl vector42
vector42:
  pushl $0
80106575:	6a 00                	push   $0x0
  pushl $42
80106577:	6a 2a                	push   $0x2a
  jmp alltraps
80106579:	e9 70 f5 ff ff       	jmp    80105aee <alltraps>

8010657e <vector43>:
.globl vector43
vector43:
  pushl $0
8010657e:	6a 00                	push   $0x0
  pushl $43
80106580:	6a 2b                	push   $0x2b
  jmp alltraps
80106582:	e9 67 f5 ff ff       	jmp    80105aee <alltraps>

80106587 <vector44>:
.globl vector44
vector44:
  pushl $0
80106587:	6a 00                	push   $0x0
  pushl $44
80106589:	6a 2c                	push   $0x2c
  jmp alltraps
8010658b:	e9 5e f5 ff ff       	jmp    80105aee <alltraps>

80106590 <vector45>:
.globl vector45
vector45:
  pushl $0
80106590:	6a 00                	push   $0x0
  pushl $45
80106592:	6a 2d                	push   $0x2d
  jmp alltraps
80106594:	e9 55 f5 ff ff       	jmp    80105aee <alltraps>

80106599 <vector46>:
.globl vector46
vector46:
  pushl $0
80106599:	6a 00                	push   $0x0
  pushl $46
8010659b:	6a 2e                	push   $0x2e
  jmp alltraps
8010659d:	e9 4c f5 ff ff       	jmp    80105aee <alltraps>

801065a2 <vector47>:
.globl vector47
vector47:
  pushl $0
801065a2:	6a 00                	push   $0x0
  pushl $47
801065a4:	6a 2f                	push   $0x2f
  jmp alltraps
801065a6:	e9 43 f5 ff ff       	jmp    80105aee <alltraps>

801065ab <vector48>:
.globl vector48
vector48:
  pushl $0
801065ab:	6a 00                	push   $0x0
  pushl $48
801065ad:	6a 30                	push   $0x30
  jmp alltraps
801065af:	e9 3a f5 ff ff       	jmp    80105aee <alltraps>

801065b4 <vector49>:
.globl vector49
vector49:
  pushl $0
801065b4:	6a 00                	push   $0x0
  pushl $49
801065b6:	6a 31                	push   $0x31
  jmp alltraps
801065b8:	e9 31 f5 ff ff       	jmp    80105aee <alltraps>

801065bd <vector50>:
.globl vector50
vector50:
  pushl $0
801065bd:	6a 00                	push   $0x0
  pushl $50
801065bf:	6a 32                	push   $0x32
  jmp alltraps
801065c1:	e9 28 f5 ff ff       	jmp    80105aee <alltraps>

801065c6 <vector51>:
.globl vector51
vector51:
  pushl $0
801065c6:	6a 00                	push   $0x0
  pushl $51
801065c8:	6a 33                	push   $0x33
  jmp alltraps
801065ca:	e9 1f f5 ff ff       	jmp    80105aee <alltraps>

801065cf <vector52>:
.globl vector52
vector52:
  pushl $0
801065cf:	6a 00                	push   $0x0
  pushl $52
801065d1:	6a 34                	push   $0x34
  jmp alltraps
801065d3:	e9 16 f5 ff ff       	jmp    80105aee <alltraps>

801065d8 <vector53>:
.globl vector53
vector53:
  pushl $0
801065d8:	6a 00                	push   $0x0
  pushl $53
801065da:	6a 35                	push   $0x35
  jmp alltraps
801065dc:	e9 0d f5 ff ff       	jmp    80105aee <alltraps>

801065e1 <vector54>:
.globl vector54
vector54:
  pushl $0
801065e1:	6a 00                	push   $0x0
  pushl $54
801065e3:	6a 36                	push   $0x36
  jmp alltraps
801065e5:	e9 04 f5 ff ff       	jmp    80105aee <alltraps>

801065ea <vector55>:
.globl vector55
vector55:
  pushl $0
801065ea:	6a 00                	push   $0x0
  pushl $55
801065ec:	6a 37                	push   $0x37
  jmp alltraps
801065ee:	e9 fb f4 ff ff       	jmp    80105aee <alltraps>

801065f3 <vector56>:
.globl vector56
vector56:
  pushl $0
801065f3:	6a 00                	push   $0x0
  pushl $56
801065f5:	6a 38                	push   $0x38
  jmp alltraps
801065f7:	e9 f2 f4 ff ff       	jmp    80105aee <alltraps>

801065fc <vector57>:
.globl vector57
vector57:
  pushl $0
801065fc:	6a 00                	push   $0x0
  pushl $57
801065fe:	6a 39                	push   $0x39
  jmp alltraps
80106600:	e9 e9 f4 ff ff       	jmp    80105aee <alltraps>

80106605 <vector58>:
.globl vector58
vector58:
  pushl $0
80106605:	6a 00                	push   $0x0
  pushl $58
80106607:	6a 3a                	push   $0x3a
  jmp alltraps
80106609:	e9 e0 f4 ff ff       	jmp    80105aee <alltraps>

8010660e <vector59>:
.globl vector59
vector59:
  pushl $0
8010660e:	6a 00                	push   $0x0
  pushl $59
80106610:	6a 3b                	push   $0x3b
  jmp alltraps
80106612:	e9 d7 f4 ff ff       	jmp    80105aee <alltraps>

80106617 <vector60>:
.globl vector60
vector60:
  pushl $0
80106617:	6a 00                	push   $0x0
  pushl $60
80106619:	6a 3c                	push   $0x3c
  jmp alltraps
8010661b:	e9 ce f4 ff ff       	jmp    80105aee <alltraps>

80106620 <vector61>:
.globl vector61
vector61:
  pushl $0
80106620:	6a 00                	push   $0x0
  pushl $61
80106622:	6a 3d                	push   $0x3d
  jmp alltraps
80106624:	e9 c5 f4 ff ff       	jmp    80105aee <alltraps>

80106629 <vector62>:
.globl vector62
vector62:
  pushl $0
80106629:	6a 00                	push   $0x0
  pushl $62
8010662b:	6a 3e                	push   $0x3e
  jmp alltraps
8010662d:	e9 bc f4 ff ff       	jmp    80105aee <alltraps>

80106632 <vector63>:
.globl vector63
vector63:
  pushl $0
80106632:	6a 00                	push   $0x0
  pushl $63
80106634:	6a 3f                	push   $0x3f
  jmp alltraps
80106636:	e9 b3 f4 ff ff       	jmp    80105aee <alltraps>

8010663b <vector64>:
.globl vector64
vector64:
  pushl $0
8010663b:	6a 00                	push   $0x0
  pushl $64
8010663d:	6a 40                	push   $0x40
  jmp alltraps
8010663f:	e9 aa f4 ff ff       	jmp    80105aee <alltraps>

80106644 <vector65>:
.globl vector65
vector65:
  pushl $0
80106644:	6a 00                	push   $0x0
  pushl $65
80106646:	6a 41                	push   $0x41
  jmp alltraps
80106648:	e9 a1 f4 ff ff       	jmp    80105aee <alltraps>

8010664d <vector66>:
.globl vector66
vector66:
  pushl $0
8010664d:	6a 00                	push   $0x0
  pushl $66
8010664f:	6a 42                	push   $0x42
  jmp alltraps
80106651:	e9 98 f4 ff ff       	jmp    80105aee <alltraps>

80106656 <vector67>:
.globl vector67
vector67:
  pushl $0
80106656:	6a 00                	push   $0x0
  pushl $67
80106658:	6a 43                	push   $0x43
  jmp alltraps
8010665a:	e9 8f f4 ff ff       	jmp    80105aee <alltraps>

8010665f <vector68>:
.globl vector68
vector68:
  pushl $0
8010665f:	6a 00                	push   $0x0
  pushl $68
80106661:	6a 44                	push   $0x44
  jmp alltraps
80106663:	e9 86 f4 ff ff       	jmp    80105aee <alltraps>

80106668 <vector69>:
.globl vector69
vector69:
  pushl $0
80106668:	6a 00                	push   $0x0
  pushl $69
8010666a:	6a 45                	push   $0x45
  jmp alltraps
8010666c:	e9 7d f4 ff ff       	jmp    80105aee <alltraps>

80106671 <vector70>:
.globl vector70
vector70:
  pushl $0
80106671:	6a 00                	push   $0x0
  pushl $70
80106673:	6a 46                	push   $0x46
  jmp alltraps
80106675:	e9 74 f4 ff ff       	jmp    80105aee <alltraps>

8010667a <vector71>:
.globl vector71
vector71:
  pushl $0
8010667a:	6a 00                	push   $0x0
  pushl $71
8010667c:	6a 47                	push   $0x47
  jmp alltraps
8010667e:	e9 6b f4 ff ff       	jmp    80105aee <alltraps>

80106683 <vector72>:
.globl vector72
vector72:
  pushl $0
80106683:	6a 00                	push   $0x0
  pushl $72
80106685:	6a 48                	push   $0x48
  jmp alltraps
80106687:	e9 62 f4 ff ff       	jmp    80105aee <alltraps>

8010668c <vector73>:
.globl vector73
vector73:
  pushl $0
8010668c:	6a 00                	push   $0x0
  pushl $73
8010668e:	6a 49                	push   $0x49
  jmp alltraps
80106690:	e9 59 f4 ff ff       	jmp    80105aee <alltraps>

80106695 <vector74>:
.globl vector74
vector74:
  pushl $0
80106695:	6a 00                	push   $0x0
  pushl $74
80106697:	6a 4a                	push   $0x4a
  jmp alltraps
80106699:	e9 50 f4 ff ff       	jmp    80105aee <alltraps>

8010669e <vector75>:
.globl vector75
vector75:
  pushl $0
8010669e:	6a 00                	push   $0x0
  pushl $75
801066a0:	6a 4b                	push   $0x4b
  jmp alltraps
801066a2:	e9 47 f4 ff ff       	jmp    80105aee <alltraps>

801066a7 <vector76>:
.globl vector76
vector76:
  pushl $0
801066a7:	6a 00                	push   $0x0
  pushl $76
801066a9:	6a 4c                	push   $0x4c
  jmp alltraps
801066ab:	e9 3e f4 ff ff       	jmp    80105aee <alltraps>

801066b0 <vector77>:
.globl vector77
vector77:
  pushl $0
801066b0:	6a 00                	push   $0x0
  pushl $77
801066b2:	6a 4d                	push   $0x4d
  jmp alltraps
801066b4:	e9 35 f4 ff ff       	jmp    80105aee <alltraps>

801066b9 <vector78>:
.globl vector78
vector78:
  pushl $0
801066b9:	6a 00                	push   $0x0
  pushl $78
801066bb:	6a 4e                	push   $0x4e
  jmp alltraps
801066bd:	e9 2c f4 ff ff       	jmp    80105aee <alltraps>

801066c2 <vector79>:
.globl vector79
vector79:
  pushl $0
801066c2:	6a 00                	push   $0x0
  pushl $79
801066c4:	6a 4f                	push   $0x4f
  jmp alltraps
801066c6:	e9 23 f4 ff ff       	jmp    80105aee <alltraps>

801066cb <vector80>:
.globl vector80
vector80:
  pushl $0
801066cb:	6a 00                	push   $0x0
  pushl $80
801066cd:	6a 50                	push   $0x50
  jmp alltraps
801066cf:	e9 1a f4 ff ff       	jmp    80105aee <alltraps>

801066d4 <vector81>:
.globl vector81
vector81:
  pushl $0
801066d4:	6a 00                	push   $0x0
  pushl $81
801066d6:	6a 51                	push   $0x51
  jmp alltraps
801066d8:	e9 11 f4 ff ff       	jmp    80105aee <alltraps>

801066dd <vector82>:
.globl vector82
vector82:
  pushl $0
801066dd:	6a 00                	push   $0x0
  pushl $82
801066df:	6a 52                	push   $0x52
  jmp alltraps
801066e1:	e9 08 f4 ff ff       	jmp    80105aee <alltraps>

801066e6 <vector83>:
.globl vector83
vector83:
  pushl $0
801066e6:	6a 00                	push   $0x0
  pushl $83
801066e8:	6a 53                	push   $0x53
  jmp alltraps
801066ea:	e9 ff f3 ff ff       	jmp    80105aee <alltraps>

801066ef <vector84>:
.globl vector84
vector84:
  pushl $0
801066ef:	6a 00                	push   $0x0
  pushl $84
801066f1:	6a 54                	push   $0x54
  jmp alltraps
801066f3:	e9 f6 f3 ff ff       	jmp    80105aee <alltraps>

801066f8 <vector85>:
.globl vector85
vector85:
  pushl $0
801066f8:	6a 00                	push   $0x0
  pushl $85
801066fa:	6a 55                	push   $0x55
  jmp alltraps
801066fc:	e9 ed f3 ff ff       	jmp    80105aee <alltraps>

80106701 <vector86>:
.globl vector86
vector86:
  pushl $0
80106701:	6a 00                	push   $0x0
  pushl $86
80106703:	6a 56                	push   $0x56
  jmp alltraps
80106705:	e9 e4 f3 ff ff       	jmp    80105aee <alltraps>

8010670a <vector87>:
.globl vector87
vector87:
  pushl $0
8010670a:	6a 00                	push   $0x0
  pushl $87
8010670c:	6a 57                	push   $0x57
  jmp alltraps
8010670e:	e9 db f3 ff ff       	jmp    80105aee <alltraps>

80106713 <vector88>:
.globl vector88
vector88:
  pushl $0
80106713:	6a 00                	push   $0x0
  pushl $88
80106715:	6a 58                	push   $0x58
  jmp alltraps
80106717:	e9 d2 f3 ff ff       	jmp    80105aee <alltraps>

8010671c <vector89>:
.globl vector89
vector89:
  pushl $0
8010671c:	6a 00                	push   $0x0
  pushl $89
8010671e:	6a 59                	push   $0x59
  jmp alltraps
80106720:	e9 c9 f3 ff ff       	jmp    80105aee <alltraps>

80106725 <vector90>:
.globl vector90
vector90:
  pushl $0
80106725:	6a 00                	push   $0x0
  pushl $90
80106727:	6a 5a                	push   $0x5a
  jmp alltraps
80106729:	e9 c0 f3 ff ff       	jmp    80105aee <alltraps>

8010672e <vector91>:
.globl vector91
vector91:
  pushl $0
8010672e:	6a 00                	push   $0x0
  pushl $91
80106730:	6a 5b                	push   $0x5b
  jmp alltraps
80106732:	e9 b7 f3 ff ff       	jmp    80105aee <alltraps>

80106737 <vector92>:
.globl vector92
vector92:
  pushl $0
80106737:	6a 00                	push   $0x0
  pushl $92
80106739:	6a 5c                	push   $0x5c
  jmp alltraps
8010673b:	e9 ae f3 ff ff       	jmp    80105aee <alltraps>

80106740 <vector93>:
.globl vector93
vector93:
  pushl $0
80106740:	6a 00                	push   $0x0
  pushl $93
80106742:	6a 5d                	push   $0x5d
  jmp alltraps
80106744:	e9 a5 f3 ff ff       	jmp    80105aee <alltraps>

80106749 <vector94>:
.globl vector94
vector94:
  pushl $0
80106749:	6a 00                	push   $0x0
  pushl $94
8010674b:	6a 5e                	push   $0x5e
  jmp alltraps
8010674d:	e9 9c f3 ff ff       	jmp    80105aee <alltraps>

80106752 <vector95>:
.globl vector95
vector95:
  pushl $0
80106752:	6a 00                	push   $0x0
  pushl $95
80106754:	6a 5f                	push   $0x5f
  jmp alltraps
80106756:	e9 93 f3 ff ff       	jmp    80105aee <alltraps>

8010675b <vector96>:
.globl vector96
vector96:
  pushl $0
8010675b:	6a 00                	push   $0x0
  pushl $96
8010675d:	6a 60                	push   $0x60
  jmp alltraps
8010675f:	e9 8a f3 ff ff       	jmp    80105aee <alltraps>

80106764 <vector97>:
.globl vector97
vector97:
  pushl $0
80106764:	6a 00                	push   $0x0
  pushl $97
80106766:	6a 61                	push   $0x61
  jmp alltraps
80106768:	e9 81 f3 ff ff       	jmp    80105aee <alltraps>

8010676d <vector98>:
.globl vector98
vector98:
  pushl $0
8010676d:	6a 00                	push   $0x0
  pushl $98
8010676f:	6a 62                	push   $0x62
  jmp alltraps
80106771:	e9 78 f3 ff ff       	jmp    80105aee <alltraps>

80106776 <vector99>:
.globl vector99
vector99:
  pushl $0
80106776:	6a 00                	push   $0x0
  pushl $99
80106778:	6a 63                	push   $0x63
  jmp alltraps
8010677a:	e9 6f f3 ff ff       	jmp    80105aee <alltraps>

8010677f <vector100>:
.globl vector100
vector100:
  pushl $0
8010677f:	6a 00                	push   $0x0
  pushl $100
80106781:	6a 64                	push   $0x64
  jmp alltraps
80106783:	e9 66 f3 ff ff       	jmp    80105aee <alltraps>

80106788 <vector101>:
.globl vector101
vector101:
  pushl $0
80106788:	6a 00                	push   $0x0
  pushl $101
8010678a:	6a 65                	push   $0x65
  jmp alltraps
8010678c:	e9 5d f3 ff ff       	jmp    80105aee <alltraps>

80106791 <vector102>:
.globl vector102
vector102:
  pushl $0
80106791:	6a 00                	push   $0x0
  pushl $102
80106793:	6a 66                	push   $0x66
  jmp alltraps
80106795:	e9 54 f3 ff ff       	jmp    80105aee <alltraps>

8010679a <vector103>:
.globl vector103
vector103:
  pushl $0
8010679a:	6a 00                	push   $0x0
  pushl $103
8010679c:	6a 67                	push   $0x67
  jmp alltraps
8010679e:	e9 4b f3 ff ff       	jmp    80105aee <alltraps>

801067a3 <vector104>:
.globl vector104
vector104:
  pushl $0
801067a3:	6a 00                	push   $0x0
  pushl $104
801067a5:	6a 68                	push   $0x68
  jmp alltraps
801067a7:	e9 42 f3 ff ff       	jmp    80105aee <alltraps>

801067ac <vector105>:
.globl vector105
vector105:
  pushl $0
801067ac:	6a 00                	push   $0x0
  pushl $105
801067ae:	6a 69                	push   $0x69
  jmp alltraps
801067b0:	e9 39 f3 ff ff       	jmp    80105aee <alltraps>

801067b5 <vector106>:
.globl vector106
vector106:
  pushl $0
801067b5:	6a 00                	push   $0x0
  pushl $106
801067b7:	6a 6a                	push   $0x6a
  jmp alltraps
801067b9:	e9 30 f3 ff ff       	jmp    80105aee <alltraps>

801067be <vector107>:
.globl vector107
vector107:
  pushl $0
801067be:	6a 00                	push   $0x0
  pushl $107
801067c0:	6a 6b                	push   $0x6b
  jmp alltraps
801067c2:	e9 27 f3 ff ff       	jmp    80105aee <alltraps>

801067c7 <vector108>:
.globl vector108
vector108:
  pushl $0
801067c7:	6a 00                	push   $0x0
  pushl $108
801067c9:	6a 6c                	push   $0x6c
  jmp alltraps
801067cb:	e9 1e f3 ff ff       	jmp    80105aee <alltraps>

801067d0 <vector109>:
.globl vector109
vector109:
  pushl $0
801067d0:	6a 00                	push   $0x0
  pushl $109
801067d2:	6a 6d                	push   $0x6d
  jmp alltraps
801067d4:	e9 15 f3 ff ff       	jmp    80105aee <alltraps>

801067d9 <vector110>:
.globl vector110
vector110:
  pushl $0
801067d9:	6a 00                	push   $0x0
  pushl $110
801067db:	6a 6e                	push   $0x6e
  jmp alltraps
801067dd:	e9 0c f3 ff ff       	jmp    80105aee <alltraps>

801067e2 <vector111>:
.globl vector111
vector111:
  pushl $0
801067e2:	6a 00                	push   $0x0
  pushl $111
801067e4:	6a 6f                	push   $0x6f
  jmp alltraps
801067e6:	e9 03 f3 ff ff       	jmp    80105aee <alltraps>

801067eb <vector112>:
.globl vector112
vector112:
  pushl $0
801067eb:	6a 00                	push   $0x0
  pushl $112
801067ed:	6a 70                	push   $0x70
  jmp alltraps
801067ef:	e9 fa f2 ff ff       	jmp    80105aee <alltraps>

801067f4 <vector113>:
.globl vector113
vector113:
  pushl $0
801067f4:	6a 00                	push   $0x0
  pushl $113
801067f6:	6a 71                	push   $0x71
  jmp alltraps
801067f8:	e9 f1 f2 ff ff       	jmp    80105aee <alltraps>

801067fd <vector114>:
.globl vector114
vector114:
  pushl $0
801067fd:	6a 00                	push   $0x0
  pushl $114
801067ff:	6a 72                	push   $0x72
  jmp alltraps
80106801:	e9 e8 f2 ff ff       	jmp    80105aee <alltraps>

80106806 <vector115>:
.globl vector115
vector115:
  pushl $0
80106806:	6a 00                	push   $0x0
  pushl $115
80106808:	6a 73                	push   $0x73
  jmp alltraps
8010680a:	e9 df f2 ff ff       	jmp    80105aee <alltraps>

8010680f <vector116>:
.globl vector116
vector116:
  pushl $0
8010680f:	6a 00                	push   $0x0
  pushl $116
80106811:	6a 74                	push   $0x74
  jmp alltraps
80106813:	e9 d6 f2 ff ff       	jmp    80105aee <alltraps>

80106818 <vector117>:
.globl vector117
vector117:
  pushl $0
80106818:	6a 00                	push   $0x0
  pushl $117
8010681a:	6a 75                	push   $0x75
  jmp alltraps
8010681c:	e9 cd f2 ff ff       	jmp    80105aee <alltraps>

80106821 <vector118>:
.globl vector118
vector118:
  pushl $0
80106821:	6a 00                	push   $0x0
  pushl $118
80106823:	6a 76                	push   $0x76
  jmp alltraps
80106825:	e9 c4 f2 ff ff       	jmp    80105aee <alltraps>

8010682a <vector119>:
.globl vector119
vector119:
  pushl $0
8010682a:	6a 00                	push   $0x0
  pushl $119
8010682c:	6a 77                	push   $0x77
  jmp alltraps
8010682e:	e9 bb f2 ff ff       	jmp    80105aee <alltraps>

80106833 <vector120>:
.globl vector120
vector120:
  pushl $0
80106833:	6a 00                	push   $0x0
  pushl $120
80106835:	6a 78                	push   $0x78
  jmp alltraps
80106837:	e9 b2 f2 ff ff       	jmp    80105aee <alltraps>

8010683c <vector121>:
.globl vector121
vector121:
  pushl $0
8010683c:	6a 00                	push   $0x0
  pushl $121
8010683e:	6a 79                	push   $0x79
  jmp alltraps
80106840:	e9 a9 f2 ff ff       	jmp    80105aee <alltraps>

80106845 <vector122>:
.globl vector122
vector122:
  pushl $0
80106845:	6a 00                	push   $0x0
  pushl $122
80106847:	6a 7a                	push   $0x7a
  jmp alltraps
80106849:	e9 a0 f2 ff ff       	jmp    80105aee <alltraps>

8010684e <vector123>:
.globl vector123
vector123:
  pushl $0
8010684e:	6a 00                	push   $0x0
  pushl $123
80106850:	6a 7b                	push   $0x7b
  jmp alltraps
80106852:	e9 97 f2 ff ff       	jmp    80105aee <alltraps>

80106857 <vector124>:
.globl vector124
vector124:
  pushl $0
80106857:	6a 00                	push   $0x0
  pushl $124
80106859:	6a 7c                	push   $0x7c
  jmp alltraps
8010685b:	e9 8e f2 ff ff       	jmp    80105aee <alltraps>

80106860 <vector125>:
.globl vector125
vector125:
  pushl $0
80106860:	6a 00                	push   $0x0
  pushl $125
80106862:	6a 7d                	push   $0x7d
  jmp alltraps
80106864:	e9 85 f2 ff ff       	jmp    80105aee <alltraps>

80106869 <vector126>:
.globl vector126
vector126:
  pushl $0
80106869:	6a 00                	push   $0x0
  pushl $126
8010686b:	6a 7e                	push   $0x7e
  jmp alltraps
8010686d:	e9 7c f2 ff ff       	jmp    80105aee <alltraps>

80106872 <vector127>:
.globl vector127
vector127:
  pushl $0
80106872:	6a 00                	push   $0x0
  pushl $127
80106874:	6a 7f                	push   $0x7f
  jmp alltraps
80106876:	e9 73 f2 ff ff       	jmp    80105aee <alltraps>

8010687b <vector128>:
.globl vector128
vector128:
  pushl $0
8010687b:	6a 00                	push   $0x0
  pushl $128
8010687d:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106882:	e9 67 f2 ff ff       	jmp    80105aee <alltraps>

80106887 <vector129>:
.globl vector129
vector129:
  pushl $0
80106887:	6a 00                	push   $0x0
  pushl $129
80106889:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010688e:	e9 5b f2 ff ff       	jmp    80105aee <alltraps>

80106893 <vector130>:
.globl vector130
vector130:
  pushl $0
80106893:	6a 00                	push   $0x0
  pushl $130
80106895:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010689a:	e9 4f f2 ff ff       	jmp    80105aee <alltraps>

8010689f <vector131>:
.globl vector131
vector131:
  pushl $0
8010689f:	6a 00                	push   $0x0
  pushl $131
801068a1:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801068a6:	e9 43 f2 ff ff       	jmp    80105aee <alltraps>

801068ab <vector132>:
.globl vector132
vector132:
  pushl $0
801068ab:	6a 00                	push   $0x0
  pushl $132
801068ad:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801068b2:	e9 37 f2 ff ff       	jmp    80105aee <alltraps>

801068b7 <vector133>:
.globl vector133
vector133:
  pushl $0
801068b7:	6a 00                	push   $0x0
  pushl $133
801068b9:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801068be:	e9 2b f2 ff ff       	jmp    80105aee <alltraps>

801068c3 <vector134>:
.globl vector134
vector134:
  pushl $0
801068c3:	6a 00                	push   $0x0
  pushl $134
801068c5:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801068ca:	e9 1f f2 ff ff       	jmp    80105aee <alltraps>

801068cf <vector135>:
.globl vector135
vector135:
  pushl $0
801068cf:	6a 00                	push   $0x0
  pushl $135
801068d1:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801068d6:	e9 13 f2 ff ff       	jmp    80105aee <alltraps>

801068db <vector136>:
.globl vector136
vector136:
  pushl $0
801068db:	6a 00                	push   $0x0
  pushl $136
801068dd:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801068e2:	e9 07 f2 ff ff       	jmp    80105aee <alltraps>

801068e7 <vector137>:
.globl vector137
vector137:
  pushl $0
801068e7:	6a 00                	push   $0x0
  pushl $137
801068e9:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801068ee:	e9 fb f1 ff ff       	jmp    80105aee <alltraps>

801068f3 <vector138>:
.globl vector138
vector138:
  pushl $0
801068f3:	6a 00                	push   $0x0
  pushl $138
801068f5:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801068fa:	e9 ef f1 ff ff       	jmp    80105aee <alltraps>

801068ff <vector139>:
.globl vector139
vector139:
  pushl $0
801068ff:	6a 00                	push   $0x0
  pushl $139
80106901:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106906:	e9 e3 f1 ff ff       	jmp    80105aee <alltraps>

8010690b <vector140>:
.globl vector140
vector140:
  pushl $0
8010690b:	6a 00                	push   $0x0
  pushl $140
8010690d:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106912:	e9 d7 f1 ff ff       	jmp    80105aee <alltraps>

80106917 <vector141>:
.globl vector141
vector141:
  pushl $0
80106917:	6a 00                	push   $0x0
  pushl $141
80106919:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010691e:	e9 cb f1 ff ff       	jmp    80105aee <alltraps>

80106923 <vector142>:
.globl vector142
vector142:
  pushl $0
80106923:	6a 00                	push   $0x0
  pushl $142
80106925:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010692a:	e9 bf f1 ff ff       	jmp    80105aee <alltraps>

8010692f <vector143>:
.globl vector143
vector143:
  pushl $0
8010692f:	6a 00                	push   $0x0
  pushl $143
80106931:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106936:	e9 b3 f1 ff ff       	jmp    80105aee <alltraps>

8010693b <vector144>:
.globl vector144
vector144:
  pushl $0
8010693b:	6a 00                	push   $0x0
  pushl $144
8010693d:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106942:	e9 a7 f1 ff ff       	jmp    80105aee <alltraps>

80106947 <vector145>:
.globl vector145
vector145:
  pushl $0
80106947:	6a 00                	push   $0x0
  pushl $145
80106949:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010694e:	e9 9b f1 ff ff       	jmp    80105aee <alltraps>

80106953 <vector146>:
.globl vector146
vector146:
  pushl $0
80106953:	6a 00                	push   $0x0
  pushl $146
80106955:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010695a:	e9 8f f1 ff ff       	jmp    80105aee <alltraps>

8010695f <vector147>:
.globl vector147
vector147:
  pushl $0
8010695f:	6a 00                	push   $0x0
  pushl $147
80106961:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106966:	e9 83 f1 ff ff       	jmp    80105aee <alltraps>

8010696b <vector148>:
.globl vector148
vector148:
  pushl $0
8010696b:	6a 00                	push   $0x0
  pushl $148
8010696d:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106972:	e9 77 f1 ff ff       	jmp    80105aee <alltraps>

80106977 <vector149>:
.globl vector149
vector149:
  pushl $0
80106977:	6a 00                	push   $0x0
  pushl $149
80106979:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010697e:	e9 6b f1 ff ff       	jmp    80105aee <alltraps>

80106983 <vector150>:
.globl vector150
vector150:
  pushl $0
80106983:	6a 00                	push   $0x0
  pushl $150
80106985:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010698a:	e9 5f f1 ff ff       	jmp    80105aee <alltraps>

8010698f <vector151>:
.globl vector151
vector151:
  pushl $0
8010698f:	6a 00                	push   $0x0
  pushl $151
80106991:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106996:	e9 53 f1 ff ff       	jmp    80105aee <alltraps>

8010699b <vector152>:
.globl vector152
vector152:
  pushl $0
8010699b:	6a 00                	push   $0x0
  pushl $152
8010699d:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801069a2:	e9 47 f1 ff ff       	jmp    80105aee <alltraps>

801069a7 <vector153>:
.globl vector153
vector153:
  pushl $0
801069a7:	6a 00                	push   $0x0
  pushl $153
801069a9:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801069ae:	e9 3b f1 ff ff       	jmp    80105aee <alltraps>

801069b3 <vector154>:
.globl vector154
vector154:
  pushl $0
801069b3:	6a 00                	push   $0x0
  pushl $154
801069b5:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801069ba:	e9 2f f1 ff ff       	jmp    80105aee <alltraps>

801069bf <vector155>:
.globl vector155
vector155:
  pushl $0
801069bf:	6a 00                	push   $0x0
  pushl $155
801069c1:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801069c6:	e9 23 f1 ff ff       	jmp    80105aee <alltraps>

801069cb <vector156>:
.globl vector156
vector156:
  pushl $0
801069cb:	6a 00                	push   $0x0
  pushl $156
801069cd:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801069d2:	e9 17 f1 ff ff       	jmp    80105aee <alltraps>

801069d7 <vector157>:
.globl vector157
vector157:
  pushl $0
801069d7:	6a 00                	push   $0x0
  pushl $157
801069d9:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801069de:	e9 0b f1 ff ff       	jmp    80105aee <alltraps>

801069e3 <vector158>:
.globl vector158
vector158:
  pushl $0
801069e3:	6a 00                	push   $0x0
  pushl $158
801069e5:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801069ea:	e9 ff f0 ff ff       	jmp    80105aee <alltraps>

801069ef <vector159>:
.globl vector159
vector159:
  pushl $0
801069ef:	6a 00                	push   $0x0
  pushl $159
801069f1:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801069f6:	e9 f3 f0 ff ff       	jmp    80105aee <alltraps>

801069fb <vector160>:
.globl vector160
vector160:
  pushl $0
801069fb:	6a 00                	push   $0x0
  pushl $160
801069fd:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106a02:	e9 e7 f0 ff ff       	jmp    80105aee <alltraps>

80106a07 <vector161>:
.globl vector161
vector161:
  pushl $0
80106a07:	6a 00                	push   $0x0
  pushl $161
80106a09:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106a0e:	e9 db f0 ff ff       	jmp    80105aee <alltraps>

80106a13 <vector162>:
.globl vector162
vector162:
  pushl $0
80106a13:	6a 00                	push   $0x0
  pushl $162
80106a15:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106a1a:	e9 cf f0 ff ff       	jmp    80105aee <alltraps>

80106a1f <vector163>:
.globl vector163
vector163:
  pushl $0
80106a1f:	6a 00                	push   $0x0
  pushl $163
80106a21:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106a26:	e9 c3 f0 ff ff       	jmp    80105aee <alltraps>

80106a2b <vector164>:
.globl vector164
vector164:
  pushl $0
80106a2b:	6a 00                	push   $0x0
  pushl $164
80106a2d:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106a32:	e9 b7 f0 ff ff       	jmp    80105aee <alltraps>

80106a37 <vector165>:
.globl vector165
vector165:
  pushl $0
80106a37:	6a 00                	push   $0x0
  pushl $165
80106a39:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106a3e:	e9 ab f0 ff ff       	jmp    80105aee <alltraps>

80106a43 <vector166>:
.globl vector166
vector166:
  pushl $0
80106a43:	6a 00                	push   $0x0
  pushl $166
80106a45:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106a4a:	e9 9f f0 ff ff       	jmp    80105aee <alltraps>

80106a4f <vector167>:
.globl vector167
vector167:
  pushl $0
80106a4f:	6a 00                	push   $0x0
  pushl $167
80106a51:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106a56:	e9 93 f0 ff ff       	jmp    80105aee <alltraps>

80106a5b <vector168>:
.globl vector168
vector168:
  pushl $0
80106a5b:	6a 00                	push   $0x0
  pushl $168
80106a5d:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106a62:	e9 87 f0 ff ff       	jmp    80105aee <alltraps>

80106a67 <vector169>:
.globl vector169
vector169:
  pushl $0
80106a67:	6a 00                	push   $0x0
  pushl $169
80106a69:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106a6e:	e9 7b f0 ff ff       	jmp    80105aee <alltraps>

80106a73 <vector170>:
.globl vector170
vector170:
  pushl $0
80106a73:	6a 00                	push   $0x0
  pushl $170
80106a75:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106a7a:	e9 6f f0 ff ff       	jmp    80105aee <alltraps>

80106a7f <vector171>:
.globl vector171
vector171:
  pushl $0
80106a7f:	6a 00                	push   $0x0
  pushl $171
80106a81:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106a86:	e9 63 f0 ff ff       	jmp    80105aee <alltraps>

80106a8b <vector172>:
.globl vector172
vector172:
  pushl $0
80106a8b:	6a 00                	push   $0x0
  pushl $172
80106a8d:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106a92:	e9 57 f0 ff ff       	jmp    80105aee <alltraps>

80106a97 <vector173>:
.globl vector173
vector173:
  pushl $0
80106a97:	6a 00                	push   $0x0
  pushl $173
80106a99:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106a9e:	e9 4b f0 ff ff       	jmp    80105aee <alltraps>

80106aa3 <vector174>:
.globl vector174
vector174:
  pushl $0
80106aa3:	6a 00                	push   $0x0
  pushl $174
80106aa5:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106aaa:	e9 3f f0 ff ff       	jmp    80105aee <alltraps>

80106aaf <vector175>:
.globl vector175
vector175:
  pushl $0
80106aaf:	6a 00                	push   $0x0
  pushl $175
80106ab1:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106ab6:	e9 33 f0 ff ff       	jmp    80105aee <alltraps>

80106abb <vector176>:
.globl vector176
vector176:
  pushl $0
80106abb:	6a 00                	push   $0x0
  pushl $176
80106abd:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106ac2:	e9 27 f0 ff ff       	jmp    80105aee <alltraps>

80106ac7 <vector177>:
.globl vector177
vector177:
  pushl $0
80106ac7:	6a 00                	push   $0x0
  pushl $177
80106ac9:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106ace:	e9 1b f0 ff ff       	jmp    80105aee <alltraps>

80106ad3 <vector178>:
.globl vector178
vector178:
  pushl $0
80106ad3:	6a 00                	push   $0x0
  pushl $178
80106ad5:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106ada:	e9 0f f0 ff ff       	jmp    80105aee <alltraps>

80106adf <vector179>:
.globl vector179
vector179:
  pushl $0
80106adf:	6a 00                	push   $0x0
  pushl $179
80106ae1:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106ae6:	e9 03 f0 ff ff       	jmp    80105aee <alltraps>

80106aeb <vector180>:
.globl vector180
vector180:
  pushl $0
80106aeb:	6a 00                	push   $0x0
  pushl $180
80106aed:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106af2:	e9 f7 ef ff ff       	jmp    80105aee <alltraps>

80106af7 <vector181>:
.globl vector181
vector181:
  pushl $0
80106af7:	6a 00                	push   $0x0
  pushl $181
80106af9:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106afe:	e9 eb ef ff ff       	jmp    80105aee <alltraps>

80106b03 <vector182>:
.globl vector182
vector182:
  pushl $0
80106b03:	6a 00                	push   $0x0
  pushl $182
80106b05:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106b0a:	e9 df ef ff ff       	jmp    80105aee <alltraps>

80106b0f <vector183>:
.globl vector183
vector183:
  pushl $0
80106b0f:	6a 00                	push   $0x0
  pushl $183
80106b11:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106b16:	e9 d3 ef ff ff       	jmp    80105aee <alltraps>

80106b1b <vector184>:
.globl vector184
vector184:
  pushl $0
80106b1b:	6a 00                	push   $0x0
  pushl $184
80106b1d:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106b22:	e9 c7 ef ff ff       	jmp    80105aee <alltraps>

80106b27 <vector185>:
.globl vector185
vector185:
  pushl $0
80106b27:	6a 00                	push   $0x0
  pushl $185
80106b29:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106b2e:	e9 bb ef ff ff       	jmp    80105aee <alltraps>

80106b33 <vector186>:
.globl vector186
vector186:
  pushl $0
80106b33:	6a 00                	push   $0x0
  pushl $186
80106b35:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106b3a:	e9 af ef ff ff       	jmp    80105aee <alltraps>

80106b3f <vector187>:
.globl vector187
vector187:
  pushl $0
80106b3f:	6a 00                	push   $0x0
  pushl $187
80106b41:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106b46:	e9 a3 ef ff ff       	jmp    80105aee <alltraps>

80106b4b <vector188>:
.globl vector188
vector188:
  pushl $0
80106b4b:	6a 00                	push   $0x0
  pushl $188
80106b4d:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106b52:	e9 97 ef ff ff       	jmp    80105aee <alltraps>

80106b57 <vector189>:
.globl vector189
vector189:
  pushl $0
80106b57:	6a 00                	push   $0x0
  pushl $189
80106b59:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106b5e:	e9 8b ef ff ff       	jmp    80105aee <alltraps>

80106b63 <vector190>:
.globl vector190
vector190:
  pushl $0
80106b63:	6a 00                	push   $0x0
  pushl $190
80106b65:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106b6a:	e9 7f ef ff ff       	jmp    80105aee <alltraps>

80106b6f <vector191>:
.globl vector191
vector191:
  pushl $0
80106b6f:	6a 00                	push   $0x0
  pushl $191
80106b71:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106b76:	e9 73 ef ff ff       	jmp    80105aee <alltraps>

80106b7b <vector192>:
.globl vector192
vector192:
  pushl $0
80106b7b:	6a 00                	push   $0x0
  pushl $192
80106b7d:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106b82:	e9 67 ef ff ff       	jmp    80105aee <alltraps>

80106b87 <vector193>:
.globl vector193
vector193:
  pushl $0
80106b87:	6a 00                	push   $0x0
  pushl $193
80106b89:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106b8e:	e9 5b ef ff ff       	jmp    80105aee <alltraps>

80106b93 <vector194>:
.globl vector194
vector194:
  pushl $0
80106b93:	6a 00                	push   $0x0
  pushl $194
80106b95:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106b9a:	e9 4f ef ff ff       	jmp    80105aee <alltraps>

80106b9f <vector195>:
.globl vector195
vector195:
  pushl $0
80106b9f:	6a 00                	push   $0x0
  pushl $195
80106ba1:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106ba6:	e9 43 ef ff ff       	jmp    80105aee <alltraps>

80106bab <vector196>:
.globl vector196
vector196:
  pushl $0
80106bab:	6a 00                	push   $0x0
  pushl $196
80106bad:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106bb2:	e9 37 ef ff ff       	jmp    80105aee <alltraps>

80106bb7 <vector197>:
.globl vector197
vector197:
  pushl $0
80106bb7:	6a 00                	push   $0x0
  pushl $197
80106bb9:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106bbe:	e9 2b ef ff ff       	jmp    80105aee <alltraps>

80106bc3 <vector198>:
.globl vector198
vector198:
  pushl $0
80106bc3:	6a 00                	push   $0x0
  pushl $198
80106bc5:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106bca:	e9 1f ef ff ff       	jmp    80105aee <alltraps>

80106bcf <vector199>:
.globl vector199
vector199:
  pushl $0
80106bcf:	6a 00                	push   $0x0
  pushl $199
80106bd1:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106bd6:	e9 13 ef ff ff       	jmp    80105aee <alltraps>

80106bdb <vector200>:
.globl vector200
vector200:
  pushl $0
80106bdb:	6a 00                	push   $0x0
  pushl $200
80106bdd:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106be2:	e9 07 ef ff ff       	jmp    80105aee <alltraps>

80106be7 <vector201>:
.globl vector201
vector201:
  pushl $0
80106be7:	6a 00                	push   $0x0
  pushl $201
80106be9:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106bee:	e9 fb ee ff ff       	jmp    80105aee <alltraps>

80106bf3 <vector202>:
.globl vector202
vector202:
  pushl $0
80106bf3:	6a 00                	push   $0x0
  pushl $202
80106bf5:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106bfa:	e9 ef ee ff ff       	jmp    80105aee <alltraps>

80106bff <vector203>:
.globl vector203
vector203:
  pushl $0
80106bff:	6a 00                	push   $0x0
  pushl $203
80106c01:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106c06:	e9 e3 ee ff ff       	jmp    80105aee <alltraps>

80106c0b <vector204>:
.globl vector204
vector204:
  pushl $0
80106c0b:	6a 00                	push   $0x0
  pushl $204
80106c0d:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106c12:	e9 d7 ee ff ff       	jmp    80105aee <alltraps>

80106c17 <vector205>:
.globl vector205
vector205:
  pushl $0
80106c17:	6a 00                	push   $0x0
  pushl $205
80106c19:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106c1e:	e9 cb ee ff ff       	jmp    80105aee <alltraps>

80106c23 <vector206>:
.globl vector206
vector206:
  pushl $0
80106c23:	6a 00                	push   $0x0
  pushl $206
80106c25:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106c2a:	e9 bf ee ff ff       	jmp    80105aee <alltraps>

80106c2f <vector207>:
.globl vector207
vector207:
  pushl $0
80106c2f:	6a 00                	push   $0x0
  pushl $207
80106c31:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106c36:	e9 b3 ee ff ff       	jmp    80105aee <alltraps>

80106c3b <vector208>:
.globl vector208
vector208:
  pushl $0
80106c3b:	6a 00                	push   $0x0
  pushl $208
80106c3d:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106c42:	e9 a7 ee ff ff       	jmp    80105aee <alltraps>

80106c47 <vector209>:
.globl vector209
vector209:
  pushl $0
80106c47:	6a 00                	push   $0x0
  pushl $209
80106c49:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106c4e:	e9 9b ee ff ff       	jmp    80105aee <alltraps>

80106c53 <vector210>:
.globl vector210
vector210:
  pushl $0
80106c53:	6a 00                	push   $0x0
  pushl $210
80106c55:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106c5a:	e9 8f ee ff ff       	jmp    80105aee <alltraps>

80106c5f <vector211>:
.globl vector211
vector211:
  pushl $0
80106c5f:	6a 00                	push   $0x0
  pushl $211
80106c61:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106c66:	e9 83 ee ff ff       	jmp    80105aee <alltraps>

80106c6b <vector212>:
.globl vector212
vector212:
  pushl $0
80106c6b:	6a 00                	push   $0x0
  pushl $212
80106c6d:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106c72:	e9 77 ee ff ff       	jmp    80105aee <alltraps>

80106c77 <vector213>:
.globl vector213
vector213:
  pushl $0
80106c77:	6a 00                	push   $0x0
  pushl $213
80106c79:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106c7e:	e9 6b ee ff ff       	jmp    80105aee <alltraps>

80106c83 <vector214>:
.globl vector214
vector214:
  pushl $0
80106c83:	6a 00                	push   $0x0
  pushl $214
80106c85:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106c8a:	e9 5f ee ff ff       	jmp    80105aee <alltraps>

80106c8f <vector215>:
.globl vector215
vector215:
  pushl $0
80106c8f:	6a 00                	push   $0x0
  pushl $215
80106c91:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106c96:	e9 53 ee ff ff       	jmp    80105aee <alltraps>

80106c9b <vector216>:
.globl vector216
vector216:
  pushl $0
80106c9b:	6a 00                	push   $0x0
  pushl $216
80106c9d:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106ca2:	e9 47 ee ff ff       	jmp    80105aee <alltraps>

80106ca7 <vector217>:
.globl vector217
vector217:
  pushl $0
80106ca7:	6a 00                	push   $0x0
  pushl $217
80106ca9:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106cae:	e9 3b ee ff ff       	jmp    80105aee <alltraps>

80106cb3 <vector218>:
.globl vector218
vector218:
  pushl $0
80106cb3:	6a 00                	push   $0x0
  pushl $218
80106cb5:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106cba:	e9 2f ee ff ff       	jmp    80105aee <alltraps>

80106cbf <vector219>:
.globl vector219
vector219:
  pushl $0
80106cbf:	6a 00                	push   $0x0
  pushl $219
80106cc1:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106cc6:	e9 23 ee ff ff       	jmp    80105aee <alltraps>

80106ccb <vector220>:
.globl vector220
vector220:
  pushl $0
80106ccb:	6a 00                	push   $0x0
  pushl $220
80106ccd:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106cd2:	e9 17 ee ff ff       	jmp    80105aee <alltraps>

80106cd7 <vector221>:
.globl vector221
vector221:
  pushl $0
80106cd7:	6a 00                	push   $0x0
  pushl $221
80106cd9:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106cde:	e9 0b ee ff ff       	jmp    80105aee <alltraps>

80106ce3 <vector222>:
.globl vector222
vector222:
  pushl $0
80106ce3:	6a 00                	push   $0x0
  pushl $222
80106ce5:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106cea:	e9 ff ed ff ff       	jmp    80105aee <alltraps>

80106cef <vector223>:
.globl vector223
vector223:
  pushl $0
80106cef:	6a 00                	push   $0x0
  pushl $223
80106cf1:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106cf6:	e9 f3 ed ff ff       	jmp    80105aee <alltraps>

80106cfb <vector224>:
.globl vector224
vector224:
  pushl $0
80106cfb:	6a 00                	push   $0x0
  pushl $224
80106cfd:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106d02:	e9 e7 ed ff ff       	jmp    80105aee <alltraps>

80106d07 <vector225>:
.globl vector225
vector225:
  pushl $0
80106d07:	6a 00                	push   $0x0
  pushl $225
80106d09:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106d0e:	e9 db ed ff ff       	jmp    80105aee <alltraps>

80106d13 <vector226>:
.globl vector226
vector226:
  pushl $0
80106d13:	6a 00                	push   $0x0
  pushl $226
80106d15:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106d1a:	e9 cf ed ff ff       	jmp    80105aee <alltraps>

80106d1f <vector227>:
.globl vector227
vector227:
  pushl $0
80106d1f:	6a 00                	push   $0x0
  pushl $227
80106d21:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106d26:	e9 c3 ed ff ff       	jmp    80105aee <alltraps>

80106d2b <vector228>:
.globl vector228
vector228:
  pushl $0
80106d2b:	6a 00                	push   $0x0
  pushl $228
80106d2d:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106d32:	e9 b7 ed ff ff       	jmp    80105aee <alltraps>

80106d37 <vector229>:
.globl vector229
vector229:
  pushl $0
80106d37:	6a 00                	push   $0x0
  pushl $229
80106d39:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106d3e:	e9 ab ed ff ff       	jmp    80105aee <alltraps>

80106d43 <vector230>:
.globl vector230
vector230:
  pushl $0
80106d43:	6a 00                	push   $0x0
  pushl $230
80106d45:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106d4a:	e9 9f ed ff ff       	jmp    80105aee <alltraps>

80106d4f <vector231>:
.globl vector231
vector231:
  pushl $0
80106d4f:	6a 00                	push   $0x0
  pushl $231
80106d51:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106d56:	e9 93 ed ff ff       	jmp    80105aee <alltraps>

80106d5b <vector232>:
.globl vector232
vector232:
  pushl $0
80106d5b:	6a 00                	push   $0x0
  pushl $232
80106d5d:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106d62:	e9 87 ed ff ff       	jmp    80105aee <alltraps>

80106d67 <vector233>:
.globl vector233
vector233:
  pushl $0
80106d67:	6a 00                	push   $0x0
  pushl $233
80106d69:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106d6e:	e9 7b ed ff ff       	jmp    80105aee <alltraps>

80106d73 <vector234>:
.globl vector234
vector234:
  pushl $0
80106d73:	6a 00                	push   $0x0
  pushl $234
80106d75:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106d7a:	e9 6f ed ff ff       	jmp    80105aee <alltraps>

80106d7f <vector235>:
.globl vector235
vector235:
  pushl $0
80106d7f:	6a 00                	push   $0x0
  pushl $235
80106d81:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106d86:	e9 63 ed ff ff       	jmp    80105aee <alltraps>

80106d8b <vector236>:
.globl vector236
vector236:
  pushl $0
80106d8b:	6a 00                	push   $0x0
  pushl $236
80106d8d:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106d92:	e9 57 ed ff ff       	jmp    80105aee <alltraps>

80106d97 <vector237>:
.globl vector237
vector237:
  pushl $0
80106d97:	6a 00                	push   $0x0
  pushl $237
80106d99:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106d9e:	e9 4b ed ff ff       	jmp    80105aee <alltraps>

80106da3 <vector238>:
.globl vector238
vector238:
  pushl $0
80106da3:	6a 00                	push   $0x0
  pushl $238
80106da5:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106daa:	e9 3f ed ff ff       	jmp    80105aee <alltraps>

80106daf <vector239>:
.globl vector239
vector239:
  pushl $0
80106daf:	6a 00                	push   $0x0
  pushl $239
80106db1:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106db6:	e9 33 ed ff ff       	jmp    80105aee <alltraps>

80106dbb <vector240>:
.globl vector240
vector240:
  pushl $0
80106dbb:	6a 00                	push   $0x0
  pushl $240
80106dbd:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106dc2:	e9 27 ed ff ff       	jmp    80105aee <alltraps>

80106dc7 <vector241>:
.globl vector241
vector241:
  pushl $0
80106dc7:	6a 00                	push   $0x0
  pushl $241
80106dc9:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106dce:	e9 1b ed ff ff       	jmp    80105aee <alltraps>

80106dd3 <vector242>:
.globl vector242
vector242:
  pushl $0
80106dd3:	6a 00                	push   $0x0
  pushl $242
80106dd5:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106dda:	e9 0f ed ff ff       	jmp    80105aee <alltraps>

80106ddf <vector243>:
.globl vector243
vector243:
  pushl $0
80106ddf:	6a 00                	push   $0x0
  pushl $243
80106de1:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106de6:	e9 03 ed ff ff       	jmp    80105aee <alltraps>

80106deb <vector244>:
.globl vector244
vector244:
  pushl $0
80106deb:	6a 00                	push   $0x0
  pushl $244
80106ded:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106df2:	e9 f7 ec ff ff       	jmp    80105aee <alltraps>

80106df7 <vector245>:
.globl vector245
vector245:
  pushl $0
80106df7:	6a 00                	push   $0x0
  pushl $245
80106df9:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106dfe:	e9 eb ec ff ff       	jmp    80105aee <alltraps>

80106e03 <vector246>:
.globl vector246
vector246:
  pushl $0
80106e03:	6a 00                	push   $0x0
  pushl $246
80106e05:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106e0a:	e9 df ec ff ff       	jmp    80105aee <alltraps>

80106e0f <vector247>:
.globl vector247
vector247:
  pushl $0
80106e0f:	6a 00                	push   $0x0
  pushl $247
80106e11:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106e16:	e9 d3 ec ff ff       	jmp    80105aee <alltraps>

80106e1b <vector248>:
.globl vector248
vector248:
  pushl $0
80106e1b:	6a 00                	push   $0x0
  pushl $248
80106e1d:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106e22:	e9 c7 ec ff ff       	jmp    80105aee <alltraps>

80106e27 <vector249>:
.globl vector249
vector249:
  pushl $0
80106e27:	6a 00                	push   $0x0
  pushl $249
80106e29:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106e2e:	e9 bb ec ff ff       	jmp    80105aee <alltraps>

80106e33 <vector250>:
.globl vector250
vector250:
  pushl $0
80106e33:	6a 00                	push   $0x0
  pushl $250
80106e35:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106e3a:	e9 af ec ff ff       	jmp    80105aee <alltraps>

80106e3f <vector251>:
.globl vector251
vector251:
  pushl $0
80106e3f:	6a 00                	push   $0x0
  pushl $251
80106e41:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106e46:	e9 a3 ec ff ff       	jmp    80105aee <alltraps>

80106e4b <vector252>:
.globl vector252
vector252:
  pushl $0
80106e4b:	6a 00                	push   $0x0
  pushl $252
80106e4d:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106e52:	e9 97 ec ff ff       	jmp    80105aee <alltraps>

80106e57 <vector253>:
.globl vector253
vector253:
  pushl $0
80106e57:	6a 00                	push   $0x0
  pushl $253
80106e59:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106e5e:	e9 8b ec ff ff       	jmp    80105aee <alltraps>

80106e63 <vector254>:
.globl vector254
vector254:
  pushl $0
80106e63:	6a 00                	push   $0x0
  pushl $254
80106e65:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106e6a:	e9 7f ec ff ff       	jmp    80105aee <alltraps>

80106e6f <vector255>:
.globl vector255
vector255:
  pushl $0
80106e6f:	6a 00                	push   $0x0
  pushl $255
80106e71:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106e76:	e9 73 ec ff ff       	jmp    80105aee <alltraps>
80106e7b:	66 90                	xchg   %ax,%ax
80106e7d:	66 90                	xchg   %ax,%ax
80106e7f:	90                   	nop

80106e80 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80106e80:	55                   	push   %ebp
80106e81:	89 e5                	mov    %esp,%ebp
80106e83:	57                   	push   %edi
80106e84:	56                   	push   %esi
80106e85:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80106e87:	c1 ea 16             	shr    $0x16,%edx
{
80106e8a:	53                   	push   %ebx
  pde = &pgdir[PDX(va)];
80106e8b:	8d 3c 90             	lea    (%eax,%edx,4),%edi
{
80106e8e:	83 ec 0c             	sub    $0xc,%esp
  if(*pde & PTE_P){
80106e91:	8b 1f                	mov    (%edi),%ebx
80106e93:	f6 c3 01             	test   $0x1,%bl
80106e96:	74 28                	je     80106ec0 <walkpgdir+0x40>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106e98:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80106e9e:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80106ea4:	89 f0                	mov    %esi,%eax
}
80106ea6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return &pgtab[PTX(va)];
80106ea9:	c1 e8 0a             	shr    $0xa,%eax
80106eac:	25 fc 0f 00 00       	and    $0xffc,%eax
80106eb1:	01 d8                	add    %ebx,%eax
}
80106eb3:	5b                   	pop    %ebx
80106eb4:	5e                   	pop    %esi
80106eb5:	5f                   	pop    %edi
80106eb6:	5d                   	pop    %ebp
80106eb7:	c3                   	ret    
80106eb8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106ebf:	90                   	nop
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106ec0:	85 c9                	test   %ecx,%ecx
80106ec2:	74 2c                	je     80106ef0 <walkpgdir+0x70>
80106ec4:	e8 37 b9 ff ff       	call   80102800 <kalloc>
80106ec9:	89 c3                	mov    %eax,%ebx
80106ecb:	85 c0                	test   %eax,%eax
80106ecd:	74 21                	je     80106ef0 <walkpgdir+0x70>
    memset(pgtab, 0, PGSIZE);
80106ecf:	83 ec 04             	sub    $0x4,%esp
80106ed2:	68 00 10 00 00       	push   $0x1000
80106ed7:	6a 00                	push   $0x0
80106ed9:	50                   	push   %eax
80106eda:	e8 41 d9 ff ff       	call   80104820 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106edf:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106ee5:	83 c4 10             	add    $0x10,%esp
80106ee8:	83 c8 07             	or     $0x7,%eax
80106eeb:	89 07                	mov    %eax,(%edi)
80106eed:	eb b5                	jmp    80106ea4 <walkpgdir+0x24>
80106eef:	90                   	nop
}
80106ef0:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return 0;
80106ef3:	31 c0                	xor    %eax,%eax
}
80106ef5:	5b                   	pop    %ebx
80106ef6:	5e                   	pop    %esi
80106ef7:	5f                   	pop    %edi
80106ef8:	5d                   	pop    %ebp
80106ef9:	c3                   	ret    
80106efa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106f00 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80106f00:	55                   	push   %ebp
80106f01:	89 e5                	mov    %esp,%ebp
80106f03:	57                   	push   %edi
80106f04:	89 c7                	mov    %eax,%edi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106f06:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
{
80106f0a:	56                   	push   %esi
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106f0b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  a = (char*)PGROUNDDOWN((uint)va);
80106f10:	89 d6                	mov    %edx,%esi
{
80106f12:	53                   	push   %ebx
  a = (char*)PGROUNDDOWN((uint)va);
80106f13:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
{
80106f19:	83 ec 1c             	sub    $0x1c,%esp
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106f1c:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80106f22:	29 f0                	sub    %esi,%eax
80106f24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106f27:	eb 1f                	jmp    80106f48 <mappages+0x48>
80106f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
80106f30:	f6 00 01             	testb  $0x1,(%eax)
80106f33:	75 45                	jne    80106f7a <mappages+0x7a>
      panic("remap in mappages in vm.c");
    *pte = pa | perm | PTE_P;
80106f35:	0b 5d 0c             	or     0xc(%ebp),%ebx
80106f38:	83 cb 01             	or     $0x1,%ebx
80106f3b:	89 18                	mov    %ebx,(%eax)
    if(a == last)
80106f3d:	3b 75 e0             	cmp    -0x20(%ebp),%esi
80106f40:	74 2e                	je     80106f70 <mappages+0x70>
      break;
    a += PGSIZE;
80106f42:	81 c6 00 10 00 00    	add    $0x1000,%esi
  for(;;){
80106f48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106f4b:	b9 01 00 00 00       	mov    $0x1,%ecx
80106f50:	89 f2                	mov    %esi,%edx
80106f52:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
80106f55:	89 f8                	mov    %edi,%eax
80106f57:	e8 24 ff ff ff       	call   80106e80 <walkpgdir>
80106f5c:	85 c0                	test   %eax,%eax
80106f5e:	75 d0                	jne    80106f30 <mappages+0x30>
    pa += PGSIZE;
  }
  return 0;
}
80106f60:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80106f63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106f68:	5b                   	pop    %ebx
80106f69:	5e                   	pop    %esi
80106f6a:	5f                   	pop    %edi
80106f6b:	5d                   	pop    %ebp
80106f6c:	c3                   	ret    
80106f6d:	8d 76 00             	lea    0x0(%esi),%esi
80106f70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80106f73:	31 c0                	xor    %eax,%eax
}
80106f75:	5b                   	pop    %ebx
80106f76:	5e                   	pop    %esi
80106f77:	5f                   	pop    %edi
80106f78:	5d                   	pop    %ebp
80106f79:	c3                   	ret    
      panic("remap in mappages in vm.c");
80106f7a:	83 ec 0c             	sub    $0xc,%esp
80106f7d:	68 96 84 10 80       	push   $0x80108496
80106f82:	e8 f9 94 ff ff       	call   80100480 <panic>
80106f87:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106f8e:	66 90                	xchg   %ax,%ax

80106f90 <deallocuvm.part.0>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
// If the page was swapped free the corresponding disk block.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106f90:	55                   	push   %ebp
80106f91:	89 e5                	mov    %esp,%ebp
80106f93:	57                   	push   %edi
80106f94:	56                   	push   %esi
80106f95:	89 c6                	mov    %eax,%esi
80106f97:	53                   	push   %ebx
80106f98:	89 d3                	mov    %edx,%ebx
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
80106f9a:	8d 91 ff 0f 00 00    	lea    0xfff(%ecx),%edx
80106fa0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106fa6:	83 ec 1c             	sub    $0x1c,%esp
80106fa9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80106fac:	39 da                	cmp    %ebx,%edx
80106fae:	73 4a                	jae    80106ffa <deallocuvm.part.0+0x6a>
80106fb0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80106fb3:	89 d7                	mov    %edx,%edi
80106fb5:	eb 1f                	jmp    80106fd6 <deallocuvm.part.0+0x46>
80106fb7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106fbe:	66 90                	xchg   %ax,%ax
    pte = walkpgdir(pgdir, (char*)a, 0);

    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;

    else if(*pte & PTE_SWAPPED){
80106fc0:	8b 00                	mov    (%eax),%eax
80106fc2:	f6 c4 02             	test   $0x2,%ah
80106fc5:	75 69                	jne    80107030 <deallocuvm.part.0+0xa0>
        uint block_id= (*pte)>>12;
        bfree_page(ROOTDEV,block_id);
      }

    else if((*pte & PTE_P) != 0){
80106fc7:	a8 01                	test   $0x1,%al
80106fc9:	75 3d                	jne    80107008 <deallocuvm.part.0+0x78>
80106fcb:	81 c7 00 10 00 00    	add    $0x1000,%edi
  for(; a  < oldsz; a += PGSIZE){
80106fd1:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80106fd4:	76 24                	jbe    80106ffa <deallocuvm.part.0+0x6a>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106fd6:	31 c9                	xor    %ecx,%ecx
80106fd8:	89 fa                	mov    %edi,%edx
80106fda:	89 f0                	mov    %esi,%eax
80106fdc:	e8 9f fe ff ff       	call   80106e80 <walkpgdir>
80106fe1:	89 c3                	mov    %eax,%ebx
    if(!pte)
80106fe3:	85 c0                	test   %eax,%eax
80106fe5:	75 d9                	jne    80106fc0 <deallocuvm.part.0+0x30>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106fe7:	89 fa                	mov    %edi,%edx
80106fe9:	81 e2 00 00 c0 ff    	and    $0xffc00000,%edx
80106fef:	8d ba 00 00 40 00    	lea    0x400000(%edx),%edi
  for(; a  < oldsz; a += PGSIZE){
80106ff5:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80106ff8:	77 dc                	ja     80106fd6 <deallocuvm.part.0+0x46>
      *pte = 0;
    }

  }
  return newsz;
}
80106ffa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106ffd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107000:	5b                   	pop    %ebx
80107001:	5e                   	pop    %esi
80107002:	5f                   	pop    %edi
80107003:	5d                   	pop    %ebp
80107004:	c3                   	ret    
80107005:	8d 76 00             	lea    0x0(%esi),%esi
      if(pa == 0)
80107008:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010700d:	74 3a                	je     80107049 <deallocuvm.part.0+0xb9>
      kfree(v);
8010700f:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
80107012:	05 00 00 00 80       	add    $0x80000000,%eax
80107017:	81 c7 00 10 00 00    	add    $0x1000,%edi
      kfree(v);
8010701d:	50                   	push   %eax
8010701e:	e8 1d b6 ff ff       	call   80102640 <kfree>
      *pte = 0;
80107023:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
80107029:	83 c4 10             	add    $0x10,%esp
8010702c:	eb a3                	jmp    80106fd1 <deallocuvm.part.0+0x41>
8010702e:	66 90                	xchg   %ax,%ax
        bfree_page(ROOTDEV,block_id);
80107030:	83 ec 08             	sub    $0x8,%esp
        uint block_id= (*pte)>>12;
80107033:	c1 e8 0c             	shr    $0xc,%eax
80107036:	81 c7 00 10 00 00    	add    $0x1000,%edi
        bfree_page(ROOTDEV,block_id);
8010703c:	50                   	push   %eax
8010703d:	6a 01                	push   $0x1
8010703f:	e8 ac a6 ff ff       	call   801016f0 <bfree_page>
80107044:	83 c4 10             	add    $0x10,%esp
80107047:	eb 88                	jmp    80106fd1 <deallocuvm.part.0+0x41>
        panic("kfree");
80107049:	83 ec 0c             	sub    $0xc,%esp
8010704c:	68 88 84 10 80       	push   $0x80108488
80107051:	e8 2a 94 ff ff       	call   80100480 <panic>
80107056:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010705d:	8d 76 00             	lea    0x0(%esi),%esi

80107060 <seginit>:
{
80107060:	f3 0f 1e fb          	endbr32 
80107064:	55                   	push   %ebp
80107065:	89 e5                	mov    %esp,%ebp
80107067:	83 ec 18             	sub    $0x18,%esp
  c = &cpus[cpuid()];
8010706a:	e8 b1 ca ff ff       	call   80103b20 <cpuid>
  pd[0] = size-1;
8010706f:	ba 37 00 00 00       	mov    $0x37,%edx
80107074:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010707a:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010707e:	c7 80 f8 37 11 80 ff 	movl   $0xffff,-0x7feec808(%eax)
80107085:	ff 00 00 
80107088:	c7 80 fc 37 11 80 00 	movl   $0xcf9a00,-0x7feec804(%eax)
8010708f:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107092:	c7 80 00 38 11 80 ff 	movl   $0xffff,-0x7feec800(%eax)
80107099:	ff 00 00 
8010709c:	c7 80 04 38 11 80 00 	movl   $0xcf9200,-0x7feec7fc(%eax)
801070a3:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801070a6:	c7 80 08 38 11 80 ff 	movl   $0xffff,-0x7feec7f8(%eax)
801070ad:	ff 00 00 
801070b0:	c7 80 0c 38 11 80 00 	movl   $0xcffa00,-0x7feec7f4(%eax)
801070b7:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801070ba:	c7 80 10 38 11 80 ff 	movl   $0xffff,-0x7feec7f0(%eax)
801070c1:	ff 00 00 
801070c4:	c7 80 14 38 11 80 00 	movl   $0xcff200,-0x7feec7ec(%eax)
801070cb:	f2 cf 00 
  lgdt(c->gdt, sizeof(c->gdt));
801070ce:	05 f0 37 11 80       	add    $0x801137f0,%eax
  pd[1] = (uint)p;
801070d3:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
801070d7:	c1 e8 10             	shr    $0x10,%eax
801070da:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801070de:	8d 45 f2             	lea    -0xe(%ebp),%eax
801070e1:	0f 01 10             	lgdtl  (%eax)
}
801070e4:	c9                   	leave  
801070e5:	c3                   	ret    
801070e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801070ed:	8d 76 00             	lea    0x0(%esi),%esi

801070f0 <switchkvm>:
{
801070f0:	f3 0f 1e fb          	endbr32 
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801070f4:	a1 04 86 11 80       	mov    0x80118604,%eax
801070f9:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801070fe:	0f 22 d8             	mov    %eax,%cr3
}
80107101:	c3                   	ret    
80107102:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80107110 <switchuvm>:
{
80107110:	f3 0f 1e fb          	endbr32 
80107114:	55                   	push   %ebp
80107115:	89 e5                	mov    %esp,%ebp
80107117:	57                   	push   %edi
80107118:	56                   	push   %esi
80107119:	53                   	push   %ebx
8010711a:	83 ec 1c             	sub    $0x1c,%esp
8010711d:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80107120:	85 f6                	test   %esi,%esi
80107122:	0f 84 cb 00 00 00    	je     801071f3 <switchuvm+0xe3>
  if(p->kstack == 0)
80107128:	8b 46 08             	mov    0x8(%esi),%eax
8010712b:	85 c0                	test   %eax,%eax
8010712d:	0f 84 da 00 00 00    	je     8010720d <switchuvm+0xfd>
  if(p->pgdir == 0)
80107133:	8b 46 04             	mov    0x4(%esi),%eax
80107136:	85 c0                	test   %eax,%eax
80107138:	0f 84 c2 00 00 00    	je     80107200 <switchuvm+0xf0>
  pushcli();
8010713e:	e8 0d d5 ff ff       	call   80104650 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107143:	e8 68 c9 ff ff       	call   80103ab0 <mycpu>
80107148:	89 c3                	mov    %eax,%ebx
8010714a:	e8 61 c9 ff ff       	call   80103ab0 <mycpu>
8010714f:	89 c7                	mov    %eax,%edi
80107151:	e8 5a c9 ff ff       	call   80103ab0 <mycpu>
80107156:	83 c7 08             	add    $0x8,%edi
80107159:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010715c:	e8 4f c9 ff ff       	call   80103ab0 <mycpu>
80107161:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80107164:	ba 67 00 00 00       	mov    $0x67,%edx
80107169:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80107170:	83 c0 08             	add    $0x8,%eax
80107173:	66 89 93 98 00 00 00 	mov    %dx,0x98(%ebx)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010717a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010717f:	83 c1 08             	add    $0x8,%ecx
80107182:	c1 e8 18             	shr    $0x18,%eax
80107185:	c1 e9 10             	shr    $0x10,%ecx
80107188:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
8010718e:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80107194:	b9 99 40 00 00       	mov    $0x4099,%ecx
80107199:	66 89 8b 9d 00 00 00 	mov    %cx,0x9d(%ebx)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801071a0:	bb 10 00 00 00       	mov    $0x10,%ebx
  mycpu()->gdt[SEG_TSS].s = 0;
801071a5:	e8 06 c9 ff ff       	call   80103ab0 <mycpu>
801071aa:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801071b1:	e8 fa c8 ff ff       	call   80103ab0 <mycpu>
801071b6:	66 89 58 10          	mov    %bx,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801071ba:	8b 5e 08             	mov    0x8(%esi),%ebx
801071bd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801071c3:	e8 e8 c8 ff ff       	call   80103ab0 <mycpu>
801071c8:	89 58 0c             	mov    %ebx,0xc(%eax)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801071cb:	e8 e0 c8 ff ff       	call   80103ab0 <mycpu>
801071d0:	66 89 78 6e          	mov    %di,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801071d4:	b8 28 00 00 00       	mov    $0x28,%eax
801071d9:	0f 00 d8             	ltr    %ax
  lcr3(V2P(p->pgdir));  // switch to process's address space
801071dc:	8b 46 04             	mov    0x4(%esi),%eax
801071df:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801071e4:	0f 22 d8             	mov    %eax,%cr3
}
801071e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801071ea:	5b                   	pop    %ebx
801071eb:	5e                   	pop    %esi
801071ec:	5f                   	pop    %edi
801071ed:	5d                   	pop    %ebp
  popcli();
801071ee:	e9 7d d5 ff ff       	jmp    80104770 <popcli>
    panic("switchuvm: no process");
801071f3:	83 ec 0c             	sub    $0xc,%esp
801071f6:	68 b0 84 10 80       	push   $0x801084b0
801071fb:	e8 80 92 ff ff       	call   80100480 <panic>
    panic("switchuvm: no pgdir");
80107200:	83 ec 0c             	sub    $0xc,%esp
80107203:	68 db 84 10 80       	push   $0x801084db
80107208:	e8 73 92 ff ff       	call   80100480 <panic>
    panic("switchuvm: no kstack");
8010720d:	83 ec 0c             	sub    $0xc,%esp
80107210:	68 c6 84 10 80       	push   $0x801084c6
80107215:	e8 66 92 ff ff       	call   80100480 <panic>
8010721a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107220 <inituvm>:
{
80107220:	f3 0f 1e fb          	endbr32 
80107224:	55                   	push   %ebp
80107225:	89 e5                	mov    %esp,%ebp
80107227:	57                   	push   %edi
80107228:	56                   	push   %esi
80107229:	53                   	push   %ebx
8010722a:	83 ec 1c             	sub    $0x1c,%esp
8010722d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107230:	8b 75 10             	mov    0x10(%ebp),%esi
80107233:	8b 7d 08             	mov    0x8(%ebp),%edi
80107236:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(sz >= PGSIZE)
80107239:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010723f:	77 4b                	ja     8010728c <inituvm+0x6c>
  mem = kalloc();
80107241:	e8 ba b5 ff ff       	call   80102800 <kalloc>
  memset(mem, 0, PGSIZE);
80107246:	83 ec 04             	sub    $0x4,%esp
80107249:	68 00 10 00 00       	push   $0x1000
  mem = kalloc();
8010724e:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80107250:	6a 00                	push   $0x0
80107252:	50                   	push   %eax
80107253:	e8 c8 d5 ff ff       	call   80104820 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107258:	58                   	pop    %eax
80107259:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010725f:	5a                   	pop    %edx
80107260:	6a 06                	push   $0x6
80107262:	b9 00 10 00 00       	mov    $0x1000,%ecx
80107267:	31 d2                	xor    %edx,%edx
80107269:	50                   	push   %eax
8010726a:	89 f8                	mov    %edi,%eax
8010726c:	e8 8f fc ff ff       	call   80106f00 <mappages>
  memmove(mem, init, sz);
80107271:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107274:	89 75 10             	mov    %esi,0x10(%ebp)
80107277:	83 c4 10             	add    $0x10,%esp
8010727a:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010727d:	89 45 0c             	mov    %eax,0xc(%ebp)
}
80107280:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107283:	5b                   	pop    %ebx
80107284:	5e                   	pop    %esi
80107285:	5f                   	pop    %edi
80107286:	5d                   	pop    %ebp
  memmove(mem, init, sz);
80107287:	e9 34 d6 ff ff       	jmp    801048c0 <memmove>
    panic("inituvm: more than a page");
8010728c:	83 ec 0c             	sub    $0xc,%esp
8010728f:	68 ef 84 10 80       	push   $0x801084ef
80107294:	e8 e7 91 ff ff       	call   80100480 <panic>
80107299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801072a0 <loaduvm>:
{
801072a0:	f3 0f 1e fb          	endbr32 
801072a4:	55                   	push   %ebp
801072a5:	89 e5                	mov    %esp,%ebp
801072a7:	57                   	push   %edi
801072a8:	56                   	push   %esi
801072a9:	53                   	push   %ebx
801072aa:	83 ec 1c             	sub    $0x1c,%esp
801072ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801072b0:	8b 75 18             	mov    0x18(%ebp),%esi
  if((uint) addr % PGSIZE != 0)
801072b3:	a9 ff 0f 00 00       	test   $0xfff,%eax
801072b8:	0f 85 99 00 00 00    	jne    80107357 <loaduvm+0xb7>
  for(i = 0; i < sz; i += PGSIZE){
801072be:	01 f0                	add    %esi,%eax
801072c0:	89 f3                	mov    %esi,%ebx
801072c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801072c5:	8b 45 14             	mov    0x14(%ebp),%eax
801072c8:	01 f0                	add    %esi,%eax
801072ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; i < sz; i += PGSIZE){
801072cd:	85 f6                	test   %esi,%esi
801072cf:	75 15                	jne    801072e6 <loaduvm+0x46>
801072d1:	eb 6d                	jmp    80107340 <loaduvm+0xa0>
801072d3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801072d7:	90                   	nop
801072d8:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
801072de:	89 f0                	mov    %esi,%eax
801072e0:	29 d8                	sub    %ebx,%eax
801072e2:	39 c6                	cmp    %eax,%esi
801072e4:	76 5a                	jbe    80107340 <loaduvm+0xa0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801072e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801072e9:	8b 45 08             	mov    0x8(%ebp),%eax
801072ec:	31 c9                	xor    %ecx,%ecx
801072ee:	29 da                	sub    %ebx,%edx
801072f0:	e8 8b fb ff ff       	call   80106e80 <walkpgdir>
801072f5:	85 c0                	test   %eax,%eax
801072f7:	74 51                	je     8010734a <loaduvm+0xaa>
    pa = PTE_ADDR(*pte);
801072f9:	8b 00                	mov    (%eax),%eax
    if(readi(ip, P2V(pa), offset+i, n) != n)
801072fb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
    if(sz - i < PGSIZE)
801072fe:	bf 00 10 00 00       	mov    $0x1000,%edi
    pa = PTE_ADDR(*pte);
80107303:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80107308:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
8010730e:	0f 46 fb             	cmovbe %ebx,%edi
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107311:	29 d9                	sub    %ebx,%ecx
80107313:	05 00 00 00 80       	add    $0x80000000,%eax
80107318:	57                   	push   %edi
80107319:	51                   	push   %ecx
8010731a:	50                   	push   %eax
8010731b:	ff 75 10             	pushl  0x10(%ebp)
8010731e:	e8 1d a9 ff ff       	call   80101c40 <readi>
80107323:	83 c4 10             	add    $0x10,%esp
80107326:	39 f8                	cmp    %edi,%eax
80107328:	74 ae                	je     801072d8 <loaduvm+0x38>
}
8010732a:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
8010732d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107332:	5b                   	pop    %ebx
80107333:	5e                   	pop    %esi
80107334:	5f                   	pop    %edi
80107335:	5d                   	pop    %ebp
80107336:	c3                   	ret    
80107337:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010733e:	66 90                	xchg   %ax,%ax
80107340:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107343:	31 c0                	xor    %eax,%eax
}
80107345:	5b                   	pop    %ebx
80107346:	5e                   	pop    %esi
80107347:	5f                   	pop    %edi
80107348:	5d                   	pop    %ebp
80107349:	c3                   	ret    
      panic("loaduvm: address should exist");
8010734a:	83 ec 0c             	sub    $0xc,%esp
8010734d:	68 09 85 10 80       	push   $0x80108509
80107352:	e8 29 91 ff ff       	call   80100480 <panic>
    panic("loaduvm: addr must be page aligned");
80107357:	83 ec 0c             	sub    $0xc,%esp
8010735a:	68 7c 85 10 80       	push   $0x8010857c
8010735f:	e8 1c 91 ff ff       	call   80100480 <panic>
80107364:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010736b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010736f:	90                   	nop

80107370 <allocuvm>:
{
80107370:	f3 0f 1e fb          	endbr32 
80107374:	55                   	push   %ebp
80107375:	89 e5                	mov    %esp,%ebp
80107377:	57                   	push   %edi
80107378:	56                   	push   %esi
80107379:	53                   	push   %ebx
8010737a:	83 ec 1c             	sub    $0x1c,%esp
  if(newsz >= KERNBASE)
8010737d:	8b 45 10             	mov    0x10(%ebp),%eax
{
80107380:	8b 7d 08             	mov    0x8(%ebp),%edi
  if(newsz >= KERNBASE)
80107383:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107386:	85 c0                	test   %eax,%eax
80107388:	0f 88 a2 00 00 00    	js     80107430 <allocuvm+0xc0>
  if(newsz < oldsz)
8010738e:	3b 45 0c             	cmp    0xc(%ebp),%eax
    return oldsz;
80107391:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(newsz < oldsz)
80107394:	0f 82 86 00 00 00    	jb     80107420 <allocuvm+0xb0>
  a = PGROUNDUP(oldsz);
8010739a:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
801073a0:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
801073a6:	39 75 10             	cmp    %esi,0x10(%ebp)
801073a9:	77 40                	ja     801073eb <allocuvm+0x7b>
801073ab:	eb 76                	jmp    80107423 <allocuvm+0xb3>
801073ad:	8d 76 00             	lea    0x0(%esi),%esi
    memset(mem, 0, PGSIZE);
801073b0:	83 ec 04             	sub    $0x4,%esp
801073b3:	68 00 10 00 00       	push   $0x1000
801073b8:	6a 00                	push   $0x0
801073ba:	50                   	push   %eax
801073bb:	e8 60 d4 ff ff       	call   80104820 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801073c0:	58                   	pop    %eax
801073c1:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801073c7:	5a                   	pop    %edx
801073c8:	6a 06                	push   $0x6
801073ca:	b9 00 10 00 00       	mov    $0x1000,%ecx
801073cf:	89 f2                	mov    %esi,%edx
801073d1:	50                   	push   %eax
801073d2:	89 f8                	mov    %edi,%eax
801073d4:	e8 27 fb ff ff       	call   80106f00 <mappages>
801073d9:	83 c4 10             	add    $0x10,%esp
801073dc:	85 c0                	test   %eax,%eax
801073de:	78 68                	js     80107448 <allocuvm+0xd8>
  for(; a < newsz; a += PGSIZE){
801073e0:	81 c6 00 10 00 00    	add    $0x1000,%esi
801073e6:	39 75 10             	cmp    %esi,0x10(%ebp)
801073e9:	76 38                	jbe    80107423 <allocuvm+0xb3>
    mem = kalloc();
801073eb:	e8 10 b4 ff ff       	call   80102800 <kalloc>
801073f0:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
801073f2:	85 c0                	test   %eax,%eax
801073f4:	75 ba                	jne    801073b0 <allocuvm+0x40>
  if(newsz >= oldsz)
801073f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801073f9:	39 45 10             	cmp    %eax,0x10(%ebp)
801073fc:	74 32                	je     80107430 <allocuvm+0xc0>
801073fe:	8b 55 10             	mov    0x10(%ebp),%edx
80107401:	89 c1                	mov    %eax,%ecx
80107403:	89 f8                	mov    %edi,%eax
80107405:	e8 86 fb ff ff       	call   80106f90 <deallocuvm.part.0>
      return 0;
8010740a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80107411:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107414:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107417:	5b                   	pop    %ebx
80107418:	5e                   	pop    %esi
80107419:	5f                   	pop    %edi
8010741a:	5d                   	pop    %ebp
8010741b:	c3                   	ret    
8010741c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return oldsz;
80107420:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}
80107423:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107426:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107429:	5b                   	pop    %ebx
8010742a:	5e                   	pop    %esi
8010742b:	5f                   	pop    %edi
8010742c:	5d                   	pop    %ebp
8010742d:	c3                   	ret    
8010742e:	66 90                	xchg   %ax,%ax
    return 0;
80107430:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80107437:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010743a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010743d:	5b                   	pop    %ebx
8010743e:	5e                   	pop    %esi
8010743f:	5f                   	pop    %edi
80107440:	5d                   	pop    %ebp
80107441:	c3                   	ret    
80107442:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  if(newsz >= oldsz)
80107448:	8b 45 0c             	mov    0xc(%ebp),%eax
8010744b:	39 45 10             	cmp    %eax,0x10(%ebp)
8010744e:	74 0c                	je     8010745c <allocuvm+0xec>
80107450:	8b 55 10             	mov    0x10(%ebp),%edx
80107453:	89 c1                	mov    %eax,%ecx
80107455:	89 f8                	mov    %edi,%eax
80107457:	e8 34 fb ff ff       	call   80106f90 <deallocuvm.part.0>
      kfree(mem);
8010745c:	83 ec 0c             	sub    $0xc,%esp
8010745f:	53                   	push   %ebx
80107460:	e8 db b1 ff ff       	call   80102640 <kfree>
      return 0;
80107465:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010746c:	83 c4 10             	add    $0x10,%esp
}
8010746f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107472:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107475:	5b                   	pop    %ebx
80107476:	5e                   	pop    %esi
80107477:	5f                   	pop    %edi
80107478:	5d                   	pop    %ebp
80107479:	c3                   	ret    
8010747a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107480 <deallocuvm>:
{
80107480:	f3 0f 1e fb          	endbr32 
80107484:	55                   	push   %ebp
80107485:	89 e5                	mov    %esp,%ebp
80107487:	8b 55 0c             	mov    0xc(%ebp),%edx
8010748a:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010748d:	8b 45 08             	mov    0x8(%ebp),%eax
  if(newsz >= oldsz)
80107490:	39 d1                	cmp    %edx,%ecx
80107492:	73 0c                	jae    801074a0 <deallocuvm+0x20>
}
80107494:	5d                   	pop    %ebp
80107495:	e9 f6 fa ff ff       	jmp    80106f90 <deallocuvm.part.0>
8010749a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801074a0:	89 d0                	mov    %edx,%eax
801074a2:	5d                   	pop    %ebp
801074a3:	c3                   	ret    
801074a4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801074ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801074af:	90                   	nop

801074b0 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801074b0:	f3 0f 1e fb          	endbr32 
801074b4:	55                   	push   %ebp
801074b5:	89 e5                	mov    %esp,%ebp
801074b7:	57                   	push   %edi
801074b8:	56                   	push   %esi
801074b9:	53                   	push   %ebx
801074ba:	83 ec 0c             	sub    $0xc,%esp
801074bd:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
801074c0:	85 f6                	test   %esi,%esi
801074c2:	74 55                	je     80107519 <freevm+0x69>
  if(newsz >= oldsz)
801074c4:	31 c9                	xor    %ecx,%ecx
801074c6:	ba 00 00 00 80       	mov    $0x80000000,%edx
801074cb:	89 f0                	mov    %esi,%eax
801074cd:	89 f3                	mov    %esi,%ebx
801074cf:	e8 bc fa ff ff       	call   80106f90 <deallocuvm.part.0>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801074d4:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
801074da:	eb 0b                	jmp    801074e7 <freevm+0x37>
801074dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801074e0:	83 c3 04             	add    $0x4,%ebx
801074e3:	39 df                	cmp    %ebx,%edi
801074e5:	74 23                	je     8010750a <freevm+0x5a>
    if(pgdir[i] & PTE_P){
801074e7:	8b 03                	mov    (%ebx),%eax
801074e9:	a8 01                	test   $0x1,%al
801074eb:	74 f3                	je     801074e0 <freevm+0x30>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801074ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
      kfree(v);
801074f2:	83 ec 0c             	sub    $0xc,%esp
801074f5:	83 c3 04             	add    $0x4,%ebx
      char * v = P2V(PTE_ADDR(pgdir[i]));
801074f8:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801074fd:	50                   	push   %eax
801074fe:	e8 3d b1 ff ff       	call   80102640 <kfree>
80107503:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107506:	39 df                	cmp    %ebx,%edi
80107508:	75 dd                	jne    801074e7 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010750a:	89 75 08             	mov    %esi,0x8(%ebp)
}
8010750d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107510:	5b                   	pop    %ebx
80107511:	5e                   	pop    %esi
80107512:	5f                   	pop    %edi
80107513:	5d                   	pop    %ebp
  kfree((char*)pgdir);
80107514:	e9 27 b1 ff ff       	jmp    80102640 <kfree>
    panic("freevm: no pgdir");
80107519:	83 ec 0c             	sub    $0xc,%esp
8010751c:	68 27 85 10 80       	push   $0x80108527
80107521:	e8 5a 8f ff ff       	call   80100480 <panic>
80107526:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010752d:	8d 76 00             	lea    0x0(%esi),%esi

80107530 <setupkvm>:
{
80107530:	f3 0f 1e fb          	endbr32 
80107534:	55                   	push   %ebp
80107535:	89 e5                	mov    %esp,%ebp
80107537:	56                   	push   %esi
80107538:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80107539:	e8 c2 b2 ff ff       	call   80102800 <kalloc>
8010753e:	89 c6                	mov    %eax,%esi
80107540:	85 c0                	test   %eax,%eax
80107542:	74 42                	je     80107586 <setupkvm+0x56>
  memset(pgdir, 0, PGSIZE);
80107544:	83 ec 04             	sub    $0x4,%esp
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107547:	bb 20 b4 10 80       	mov    $0x8010b420,%ebx
  memset(pgdir, 0, PGSIZE);
8010754c:	68 00 10 00 00       	push   $0x1000
80107551:	6a 00                	push   $0x0
80107553:	50                   	push   %eax
80107554:	e8 c7 d2 ff ff       	call   80104820 <memset>
80107559:	83 c4 10             	add    $0x10,%esp
                (uint)k->phys_start, k->perm) < 0) {
8010755c:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010755f:	83 ec 08             	sub    $0x8,%esp
80107562:	8b 4b 08             	mov    0x8(%ebx),%ecx
80107565:	ff 73 0c             	pushl  0xc(%ebx)
80107568:	8b 13                	mov    (%ebx),%edx
8010756a:	50                   	push   %eax
8010756b:	29 c1                	sub    %eax,%ecx
8010756d:	89 f0                	mov    %esi,%eax
8010756f:	e8 8c f9 ff ff       	call   80106f00 <mappages>
80107574:	83 c4 10             	add    $0x10,%esp
80107577:	85 c0                	test   %eax,%eax
80107579:	78 15                	js     80107590 <setupkvm+0x60>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010757b:	83 c3 10             	add    $0x10,%ebx
8010757e:	81 fb 60 b4 10 80    	cmp    $0x8010b460,%ebx
80107584:	75 d6                	jne    8010755c <setupkvm+0x2c>
}
80107586:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107589:	89 f0                	mov    %esi,%eax
8010758b:	5b                   	pop    %ebx
8010758c:	5e                   	pop    %esi
8010758d:	5d                   	pop    %ebp
8010758e:	c3                   	ret    
8010758f:	90                   	nop
      freevm(pgdir);
80107590:	83 ec 0c             	sub    $0xc,%esp
80107593:	56                   	push   %esi
      return 0;
80107594:	31 f6                	xor    %esi,%esi
      freevm(pgdir);
80107596:	e8 15 ff ff ff       	call   801074b0 <freevm>
      return 0;
8010759b:	83 c4 10             	add    $0x10,%esp
}
8010759e:	8d 65 f8             	lea    -0x8(%ebp),%esp
801075a1:	89 f0                	mov    %esi,%eax
801075a3:	5b                   	pop    %ebx
801075a4:	5e                   	pop    %esi
801075a5:	5d                   	pop    %ebp
801075a6:	c3                   	ret    
801075a7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801075ae:	66 90                	xchg   %ax,%ax

801075b0 <kvmalloc>:
{
801075b0:	f3 0f 1e fb          	endbr32 
801075b4:	55                   	push   %ebp
801075b5:	89 e5                	mov    %esp,%ebp
801075b7:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801075ba:	e8 71 ff ff ff       	call   80107530 <setupkvm>
801075bf:	a3 04 86 11 80       	mov    %eax,0x80118604
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801075c4:	05 00 00 00 80       	add    $0x80000000,%eax
801075c9:	0f 22 d8             	mov    %eax,%cr3
}
801075cc:	c9                   	leave  
801075cd:	c3                   	ret    
801075ce:	66 90                	xchg   %ax,%ax

801075d0 <select_a_victim>:
    of 10% of the allocated pages and call select_a_victim() again
*/

pte_t*
select_a_victim(pde_t *pgdir)     // take a pointer to process page directory  //hna bdawr 3la page table ynf3 ast5dmha aw bta3t process de
{
801075d0:	f3 0f 1e fb          	endbr32 
801075d4:	55                   	push   %ebp
801075d5:	89 e5                	mov    %esp,%ebp
801075d7:	56                   	push   %esi
  pte_t *pte;
  for(long i=4096; i<KERNBASE;i+=PGSIZE){    //for all pages in the user virtual space
801075d8:	be 00 10 00 00       	mov    $0x1000,%esi
{
801075dd:	53                   	push   %ebx
801075de:	8b 5d 08             	mov    0x8(%ebp),%ebx
  for(long i=4096; i<KERNBASE;i+=PGSIZE){    //for all pages in the user virtual space
801075e1:	eb 17                	jmp    801075fa <select_a_victim+0x2a>
801075e3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801075e7:	90                   	nop
  //  cprintf("i wala loop\t");
    if((pte=walkpgdir(pgdir,(char*)i,0))!= 0) //if mapping exists (0 as 3rd argument as we dont want to create mapping if does not exists) y3ny m3aya page table hna
		  {    // cprintf("walkpgdir successful\t");

           if(*pte & PTE_P) //if not dirty, or (present and access bit not set)  --- conditions needs to be checked
801075e8:	8b 10                	mov    (%eax),%edx
801075ea:	f6 c2 01             	test   $0x1,%dl
801075ed:	74 05                	je     801075f4 <select_a_victim+0x24>
           {   if(*pte & ~PTE_A)             //access bit is NOT set.
801075ef:	83 e2 df             	and    $0xffffffdf,%edx
801075f2:	75 2c                	jne    80107620 <select_a_victim+0x50>
  for(long i=4096; i<KERNBASE;i+=PGSIZE){    //for all pages in the user virtual space
801075f4:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte=walkpgdir(pgdir,(char*)i,0))!= 0) //if mapping exists (0 as 3rd argument as we dont want to create mapping if does not exists) y3ny m3aya page table hna
801075fa:	31 c9                	xor    %ecx,%ecx
801075fc:	89 f2                	mov    %esi,%edx
801075fe:	89 d8                	mov    %ebx,%eax
80107600:	e8 7b f8 ff ff       	call   80106e80 <walkpgdir>
80107605:	85 c0                	test   %eax,%eax
80107607:	75 df                	jne    801075e8 <select_a_victim+0x18>
               }
           }
      }
      else{

        cprintf("walkpgdir failed \n ");
80107609:	83 ec 0c             	sub    $0xc,%esp
8010760c:	68 38 85 10 80       	push   $0x80108538
80107611:	e8 8a 91 ff ff       	call   801007a0 <cprintf>
80107616:	83 c4 10             	add    $0x10,%esp
80107619:	eb d9                	jmp    801075f4 <select_a_victim+0x24>
8010761b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010761f:	90                   	nop
      }
	}

  cprintf("bahar aa gaya  ");
  return 0;
}
80107620:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107623:	5b                   	pop    %ebx
80107624:	5e                   	pop    %esi
80107625:	5d                   	pop    %ebp
80107626:	c3                   	ret    
80107627:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010762e:	66 90                	xchg   %ax,%ax

80107630 <clearaccessbit_LRU>:
}

// Clear access bit of least recently used page
void
clearaccessbit_LRU(pde_t *pgdir)  // student edit
{ pte_t *pte;
80107630:	f3 0f 1e fb          	endbr32 
80107634:	55                   	push   %ebp
80107635:	89 e5                	mov    %esp,%ebp
80107637:	56                   	push   %esi
80107638:	8b 75 08             	mov    0x8(%ebp),%esi
8010763b:	53                   	push   %ebx
  uint loadOrder = 0xFFFFFFFF;
  uint accessCnt = 0xFFFFFFFF;
  uint index = -1;
  uint* LRUPage=0;
  for(long i=4096;i<KERNBASE;i+=PGSIZE){
8010763c:	bb 00 10 00 00       	mov    $0x1000,%ebx
80107641:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if((pte=walkpgdir(pgdir,(char*)i,0))!= 0){
80107648:	89 da                	mov    %ebx,%edx
8010764a:	31 c9                	xor    %ecx,%ecx
8010764c:	89 f0                	mov    %esi,%eax
  for(long i=4096;i<KERNBASE;i+=PGSIZE){
8010764e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
      if((pte=walkpgdir(pgdir,(char*)i,0))!= 0){
80107654:	e8 27 f8 ff ff       	call   80106e80 <walkpgdir>
  for(long i=4096;i<KERNBASE;i+=PGSIZE){
80107659:	eb ed                	jmp    80107648 <clearaccessbit_LRU+0x18>
8010765b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010765f:	90                   	nop

80107660 <clearaccessbit_FIFO>:
80107660:	f3 0f 1e fb          	endbr32 
80107664:	55                   	push   %ebp
80107665:	89 e5                	mov    %esp,%ebp
80107667:	83 ec 14             	sub    $0x14,%esp
8010766a:	ff 75 08             	pushl  0x8(%ebp)
8010766d:	e8 be ff ff ff       	call   80107630 <clearaccessbit_LRU>
80107672:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80107680 <updatePageCount>:
  return;
}

// update Access Count and load order for when PGFLT interrupt is called  // student edit
void
updatePageCount (struct proc* p){
80107680:	f3 0f 1e fb          	endbr32 
80107684:	55                   	push   %ebp
80107685:	89 e5                	mov    %esp,%ebp
80107687:	56                   	push   %esi
80107688:	8b 55 08             	mov    0x8(%ebp),%edx
8010768b:	53                   	push   %ebx
	p -> pageFaultCnt ++;
	p -> accessCounter ++;
8010768c:	8b 82 bc 00 00 00    	mov    0xbc(%edx),%eax
	p -> loadOrderCounter++;
80107692:	8b 5a 7c             	mov    0x7c(%edx),%ebx
	p -> pageFaultCnt ++;
80107695:	83 82 fc 00 00 00 01 	addl   $0x1,0xfc(%edx)
	p -> accessCounter ++;
8010769c:	8d 48 01             	lea    0x1(%eax),%ecx
	p -> loadOrderCounter++;
8010769f:	8d 73 01             	lea    0x1(%ebx),%esi
	for(int i = 0; i < MAX_PHYC_PN; i++){
801076a2:	31 c0                	xor    %eax,%eax
	p -> accessCounter ++;
801076a4:	89 8a bc 00 00 00    	mov    %ecx,0xbc(%edx)
	p -> loadOrderCounter++;
801076aa:	89 72 7c             	mov    %esi,0x7c(%edx)
	for(int i = 0; i < MAX_PHYC_PN; i++){
801076ad:	8d 76 00             	lea    0x0(%esi),%esi
		if(p->accessCount[i] == -1 || p->loadOrder[i] == -1) {
801076b0:	83 bc 82 c0 00 00 00 	cmpl   $0xffffffff,0xc0(%edx,%eax,4)
801076b7:	ff 
801076b8:	74 16                	je     801076d0 <updatePageCount+0x50>
801076ba:	83 bc 82 80 00 00 00 	cmpl   $0xffffffff,0x80(%edx,%eax,4)
801076c1:	ff 
801076c2:	74 0c                	je     801076d0 <updatePageCount+0x50>
	for(int i = 0; i < MAX_PHYC_PN; i++){
801076c4:	83 c0 01             	add    $0x1,%eax
801076c7:	83 f8 0f             	cmp    $0xf,%eax
801076ca:	75 e4                	jne    801076b0 <updatePageCount+0x30>
			p->loadOrder[i] =  p -> loadOrderCounter++;
			p->accessCount[i] = p -> accessCounter;
			break;
		}
	}
}
801076cc:	5b                   	pop    %ebx
801076cd:	5e                   	pop    %esi
801076ce:	5d                   	pop    %ebp
801076cf:	c3                   	ret    
			p->loadOrder[i] =  p -> loadOrderCounter++;
801076d0:	83 c3 02             	add    $0x2,%ebx
801076d3:	8d 04 82             	lea    (%edx,%eax,4),%eax
801076d6:	89 5a 7c             	mov    %ebx,0x7c(%edx)
801076d9:	89 b0 80 00 00 00    	mov    %esi,0x80(%eax)
			p->accessCount[i] = p -> accessCounter;
801076df:	89 88 c0 00 00 00    	mov    %ecx,0xc0(%eax)
}
801076e5:	5b                   	pop    %ebx
801076e6:	5e                   	pop    %esi
801076e7:	5d                   	pop    %ebp
801076e8:	c3                   	ret    
801076e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801076f0 <printState>:

// performance  // student edit
void
printState(struct proc *p){
801076f0:	f3 0f 1e fb          	endbr32 
801076f4:	55                   	push   %ebp
801076f5:	89 e5                	mov    %esp,%ebp
801076f7:	56                   	push   %esi
801076f8:	53                   	push   %ebx
	cprintf("%d %d %d\n", sys_bstat() + MAX_PHYC_PN, p->pageFaultCnt, sys_bstat());
801076f9:	e8 52 e1 ff ff       	call   80105850 <sys_bstat>
801076fe:	89 c3                	mov    %eax,%ebx
80107700:	8b 45 08             	mov    0x8(%ebp),%eax
80107703:	8b b0 fc 00 00 00    	mov    0xfc(%eax),%esi
80107709:	e8 42 e1 ff ff       	call   80105850 <sys_bstat>
8010770e:	53                   	push   %ebx
8010770f:	83 c0 0f             	add    $0xf,%eax
80107712:	56                   	push   %esi
80107713:	50                   	push   %eax
80107714:	68 4c 85 10 80       	push   $0x8010854c
80107719:	e8 82 90 ff ff       	call   801007a0 <cprintf>
}
8010771e:	83 c4 10             	add    $0x10,%esp
80107721:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107724:	5b                   	pop    %ebx
80107725:	5e                   	pop    %esi
80107726:	5d                   	pop    %ebp
80107727:	c3                   	ret    
80107728:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010772f:	90                   	nop

80107730 <getswappedblk>:

// return the disk block-id, if the virtual address
// was swapped, -1 otherwise.
int
getswappedblk(pde_t *pgdir, uint va)
{
80107730:	f3 0f 1e fb          	endbr32 
80107734:	55                   	push   %ebp
  //***************xv7**************
  pte_t *pte= walkpgdir(pgdir,(char*)va,0);
80107735:	31 c9                	xor    %ecx,%ecx
{
80107737:	89 e5                	mov    %esp,%ebp
80107739:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte= walkpgdir(pgdir,(char*)va,0);
8010773c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010773f:	8b 45 08             	mov    0x8(%ebp),%eax
80107742:	e8 39 f7 ff ff       	call   80106e80 <walkpgdir>
  //first 20 bits contain block-id, extract them from *pte
  int block_id= (*pte)>>12;
80107747:	8b 00                	mov    (%eax),%eax
  return block_id;
}
80107749:	c9                   	leave  
  int block_id= (*pte)>>12;
8010774a:	c1 e8 0c             	shr    $0xc,%eax
}
8010774d:	c3                   	ret    
8010774e:	66 90                	xchg   %ax,%ax

80107750 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107750:	f3 0f 1e fb          	endbr32 
80107754:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107755:	31 c9                	xor    %ecx,%ecx
{
80107757:	89 e5                	mov    %esp,%ebp
80107759:	83 ec 08             	sub    $0x8,%esp
  pte = walkpgdir(pgdir, uva, 0);
8010775c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010775f:	8b 45 08             	mov    0x8(%ebp),%eax
80107762:	e8 19 f7 ff ff       	call   80106e80 <walkpgdir>
  if(pte == 0)
80107767:	85 c0                	test   %eax,%eax
80107769:	74 05                	je     80107770 <clearpteu+0x20>
    panic("clearpteu");
  *pte &= ~PTE_U;
8010776b:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010776e:	c9                   	leave  
8010776f:	c3                   	ret    
    panic("clearpteu");
80107770:	83 ec 0c             	sub    $0xc,%esp
80107773:	68 56 85 10 80       	push   $0x80108556
80107778:	e8 03 8d ff ff       	call   80100480 <panic>
8010777d:	8d 76 00             	lea    0x0(%esi),%esi

80107780 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107780:	f3 0f 1e fb          	endbr32 
80107784:	55                   	push   %ebp
80107785:	89 e5                	mov    %esp,%ebp
80107787:	57                   	push   %edi
80107788:	56                   	push   %esi
80107789:	53                   	push   %ebx
8010778a:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;
  if((d = setupkvm()) == 0)
8010778d:	e8 9e fd ff ff       	call   80107530 <setupkvm>
80107792:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107795:	85 c0                	test   %eax,%eax
80107797:	0f 84 68 01 00 00    	je     80107905 <copyuvm+0x185>
    return 0;
  // cprintf("process size is: %d",sz);
  for(i = 0; i < sz; i += PGSIZE){
8010779d:	8b 75 0c             	mov    0xc(%ebp),%esi
801077a0:	85 f6                	test   %esi,%esi
801077a2:	0f 84 5d 01 00 00    	je     80107905 <copyuvm+0x185>
      int blockid=getswappedblk(pgdir,i);      //disk id where the page was swapped
      read_page_from_disk(ROOTDEV,mem,blockid);

      *pte=V2P(mem) | PTE_W | PTE_U | PTE_P;
      *pte &= ~PTE_SWAPPED;
      lcr3(V2P(pgdir));
801077a8:	8b 45 08             	mov    0x8(%ebp),%eax
  for(i = 0; i < sz; i += PGSIZE){
801077ab:	31 ff                	xor    %edi,%edi
      lcr3(V2P(pgdir));
801077ad:	05 00 00 00 80       	add    $0x80000000,%eax
801077b2:	89 45 dc             	mov    %eax,-0x24(%ebp)
801077b5:	eb 74                	jmp    8010782b <copyuvm+0xab>
801077b7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801077be:	66 90                	xchg   %ax,%ax
      //panic("copyuvm: page not present");
    }
    //  cprintf("page was not swapped\n");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
801077c0:	e8 3b b0 ff ff       	call   80102800 <kalloc>
    pa = PTE_ADDR(*pte);
801077c5:	89 de                	mov    %ebx,%esi
    flags = PTE_FLAGS(*pte);
801077c7:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
    pa = PTE_ADDR(*pte);
801077cd:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    if((mem = kalloc()) == 0)
801077d3:	89 c2                	mov    %eax,%edx
801077d5:	85 c0                	test   %eax,%eax
801077d7:	0f 84 d3 00 00 00    	je     801078b0 <copyuvm+0x130>
      mem=kalloc();
      if(mem==0)
        cprintf("unable to get memory in copyuvm");
    }

    memmove(mem, (char*)P2V(pa), PGSIZE);
801077dd:	83 ec 04             	sub    $0x4,%esp
801077e0:	81 c6 00 00 00 80    	add    $0x80000000,%esi
801077e6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801077e9:	68 00 10 00 00       	push   $0x1000
801077ee:	56                   	push   %esi
801077ef:	52                   	push   %edx
801077f0:	e8 cb d0 ff ff       	call   801048c0 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801077f5:	58                   	pop    %eax
801077f6:	5a                   	pop    %edx
801077f7:	53                   	push   %ebx
801077f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801077fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801077fe:	b9 00 10 00 00       	mov    $0x1000,%ecx
80107803:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107809:	52                   	push   %edx
8010780a:	89 fa                	mov    %edi,%edx
8010780c:	e8 ef f6 ff ff       	call   80106f00 <mappages>
80107811:	83 c4 10             	add    $0x10,%esp
80107814:	85 c0                	test   %eax,%eax
80107816:	0f 88 d4 00 00 00    	js     801078f0 <copyuvm+0x170>
  for(i = 0; i < sz; i += PGSIZE){
8010781c:	81 c7 00 10 00 00    	add    $0x1000,%edi
80107822:	39 7d 0c             	cmp    %edi,0xc(%ebp)
80107825:	0f 86 da 00 00 00    	jbe    80107905 <copyuvm+0x185>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010782b:	8b 45 08             	mov    0x8(%ebp),%eax
8010782e:	31 c9                	xor    %ecx,%ecx
80107830:	89 fa                	mov    %edi,%edx
80107832:	e8 49 f6 ff ff       	call   80106e80 <walkpgdir>
80107837:	89 c6                	mov    %eax,%esi
80107839:	85 c0                	test   %eax,%eax
8010783b:	0f 84 e9 00 00 00    	je     8010792a <copyuvm+0x1aa>
    if(*pte & PTE_SWAPPED){
80107841:	8b 18                	mov    (%eax),%ebx
80107843:	f6 c7 02             	test   $0x2,%bh
80107846:	0f 84 74 ff ff ff    	je     801077c0 <copyuvm+0x40>
      if((mem = kalloc()) == 0)
8010784c:	e8 af af ff ff       	call   80102800 <kalloc>
80107851:	89 c3                	mov    %eax,%ebx
80107853:	85 c0                	test   %eax,%eax
80107855:	0f 84 b5 00 00 00    	je     80107910 <copyuvm+0x190>
  pte_t *pte= walkpgdir(pgdir,(char*)va,0);
8010785b:	8b 45 08             	mov    0x8(%ebp),%eax
8010785e:	31 c9                	xor    %ecx,%ecx
80107860:	89 fa                	mov    %edi,%edx
80107862:	e8 19 f6 ff ff       	call   80106e80 <walkpgdir>
      read_page_from_disk(ROOTDEV,mem,blockid);
80107867:	83 ec 04             	sub    $0x4,%esp
  int block_id= (*pte)>>12;
8010786a:	8b 10                	mov    (%eax),%edx
8010786c:	c1 ea 0c             	shr    $0xc,%edx
      read_page_from_disk(ROOTDEV,mem,blockid);
8010786f:	52                   	push   %edx
80107870:	53                   	push   %ebx
      *pte=V2P(mem) | PTE_W | PTE_U | PTE_P;
80107871:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
      read_page_from_disk(ROOTDEV,mem,blockid);
80107877:	6a 01                	push   $0x1
      *pte &= ~PTE_SWAPPED;
80107879:	80 e7 fd             	and    $0xfd,%bh
8010787c:	83 cb 07             	or     $0x7,%ebx
      read_page_from_disk(ROOTDEV,mem,blockid);
8010787f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80107882:	e8 99 8a ff ff       	call   80100320 <read_page_from_disk>
      *pte &= ~PTE_SWAPPED;
80107887:	89 1e                	mov    %ebx,(%esi)
80107889:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010788c:	0f 22 d8             	mov    %eax,%cr3
      bfree_page(ROOTDEV,blockid);
8010788f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107892:	59                   	pop    %ecx
80107893:	5b                   	pop    %ebx
80107894:	52                   	push   %edx
80107895:	6a 01                	push   $0x1
80107897:	e8 54 9e ff ff       	call   801016f0 <bfree_page>
8010789c:	8b 1e                	mov    (%esi),%ebx
8010789e:	83 c4 10             	add    $0x10,%esp
801078a1:	e9 1a ff ff ff       	jmp    801077c0 <copyuvm+0x40>
801078a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801078ad:	8d 76 00             	lea    0x0(%esi),%esi
      swap_page(pgdir);
801078b0:	83 ec 0c             	sub    $0xc,%esp
801078b3:	ff 75 08             	pushl  0x8(%ebp)
801078b6:	e8 b5 e6 ff ff       	call   80105f70 <swap_page>
      mem=kalloc();
801078bb:	e8 40 af ff ff       	call   80102800 <kalloc>
      if(mem==0)
801078c0:	83 c4 10             	add    $0x10,%esp
      mem=kalloc();
801078c3:	89 c2                	mov    %eax,%edx
      if(mem==0)
801078c5:	85 c0                	test   %eax,%eax
801078c7:	0f 85 10 ff ff ff    	jne    801077dd <copyuvm+0x5d>
        cprintf("unable to get memory in copyuvm");
801078cd:	83 ec 0c             	sub    $0xc,%esp
801078d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801078d3:	68 a0 85 10 80       	push   $0x801085a0
801078d8:	e8 c3 8e ff ff       	call   801007a0 <cprintf>
801078dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801078e0:	83 c4 10             	add    $0x10,%esp
801078e3:	e9 f5 fe ff ff       	jmp    801077dd <copyuvm+0x5d>
801078e8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801078ef:	90                   	nop
}
  //cprintf("exiting from copyuvm");
  return d;

bad:
  freevm(d);
801078f0:	83 ec 0c             	sub    $0xc,%esp
801078f3:	ff 75 e0             	pushl  -0x20(%ebp)
801078f6:	e8 b5 fb ff ff       	call   801074b0 <freevm>
  return 0;
801078fb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80107902:	83 c4 10             	add    $0x10,%esp
}
80107905:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107908:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010790b:	5b                   	pop    %ebx
8010790c:	5e                   	pop    %esi
8010790d:	5f                   	pop    %edi
8010790e:	5d                   	pop    %ebp
8010790f:	c3                   	ret    
        swap_page(pgdir);
80107910:	83 ec 0c             	sub    $0xc,%esp
80107913:	ff 75 08             	pushl  0x8(%ebp)
80107916:	e8 55 e6 ff ff       	call   80105f70 <swap_page>
        mem=kalloc();
8010791b:	e8 e0 ae ff ff       	call   80102800 <kalloc>
80107920:	83 c4 10             	add    $0x10,%esp
80107923:	89 c3                	mov    %eax,%ebx
80107925:	e9 31 ff ff ff       	jmp    8010785b <copyuvm+0xdb>
      panic("copyuvm: pte should exist");
8010792a:	83 ec 0c             	sub    $0xc,%esp
8010792d:	68 60 85 10 80       	push   $0x80108560
80107932:	e8 49 8b ff ff       	call   80100480 <panic>
80107937:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010793e:	66 90                	xchg   %ax,%ax

80107940 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107940:	f3 0f 1e fb          	endbr32 
80107944:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107945:	31 c9                	xor    %ecx,%ecx
{
80107947:	89 e5                	mov    %esp,%ebp
80107949:	83 ec 08             	sub    $0x8,%esp
  pte = walkpgdir(pgdir, uva, 0);
8010794c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010794f:	8b 45 08             	mov    0x8(%ebp),%eax
80107952:	e8 29 f5 ff ff       	call   80106e80 <walkpgdir>
  if((*pte & PTE_P) == 0)
80107957:	8b 00                	mov    (%eax),%eax
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
80107959:	c9                   	leave  
  if((*pte & PTE_U) == 0)
8010795a:	89 c2                	mov    %eax,%edx
  return (char*)P2V(PTE_ADDR(*pte));
8010795c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((*pte & PTE_U) == 0)
80107961:	83 e2 05             	and    $0x5,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80107964:	05 00 00 00 80       	add    $0x80000000,%eax
80107969:	83 fa 05             	cmp    $0x5,%edx
8010796c:	ba 00 00 00 00       	mov    $0x0,%edx
80107971:	0f 45 c2             	cmovne %edx,%eax
}
80107974:	c3                   	ret    
80107975:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010797c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80107980 <uva2pte>:

// returns the page table entry corresponding
// to a virtual address.
pte_t*
uva2pte(pde_t *pgdir, uint uva)
{
80107980:	f3 0f 1e fb          	endbr32 
80107984:	55                   	push   %ebp
  return walkpgdir(pgdir, (void*)uva, 0);
80107985:	31 c9                	xor    %ecx,%ecx
{
80107987:	89 e5                	mov    %esp,%ebp
  return walkpgdir(pgdir, (void*)uva, 0);
80107989:	8b 55 0c             	mov    0xc(%ebp),%edx
8010798c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010798f:	5d                   	pop    %ebp
  return walkpgdir(pgdir, (void*)uva, 0);
80107990:	e9 eb f4 ff ff       	jmp    80106e80 <walkpgdir>
80107995:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010799c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801079a0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801079a0:	f3 0f 1e fb          	endbr32 
801079a4:	55                   	push   %ebp
801079a5:	89 e5                	mov    %esp,%ebp
801079a7:	57                   	push   %edi
801079a8:	56                   	push   %esi
801079a9:	53                   	push   %ebx
801079aa:	83 ec 0c             	sub    $0xc,%esp
801079ad:	8b 75 14             	mov    0x14(%ebp),%esi
801079b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801079b3:	85 f6                	test   %esi,%esi
801079b5:	75 3c                	jne    801079f3 <copyout+0x53>
801079b7:	eb 67                	jmp    80107a20 <copyout+0x80>
801079b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
801079c0:	8b 55 0c             	mov    0xc(%ebp),%edx
801079c3:	89 fb                	mov    %edi,%ebx
801079c5:	29 d3                	sub    %edx,%ebx
801079c7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
801079cd:	39 f3                	cmp    %esi,%ebx
801079cf:	0f 47 de             	cmova  %esi,%ebx
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801079d2:	29 fa                	sub    %edi,%edx
801079d4:	83 ec 04             	sub    $0x4,%esp
801079d7:	01 c2                	add    %eax,%edx
801079d9:	53                   	push   %ebx
801079da:	ff 75 10             	pushl  0x10(%ebp)
801079dd:	52                   	push   %edx
801079de:	e8 dd ce ff ff       	call   801048c0 <memmove>
    len -= n;
    buf += n;
801079e3:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
801079e6:	8d 97 00 10 00 00    	lea    0x1000(%edi),%edx
  while(len > 0){
801079ec:	83 c4 10             	add    $0x10,%esp
801079ef:	29 de                	sub    %ebx,%esi
801079f1:	74 2d                	je     80107a20 <copyout+0x80>
    va0 = (uint)PGROUNDDOWN(va);
801079f3:	89 d7                	mov    %edx,%edi
    pa0 = uva2ka(pgdir, (char*)va0);
801079f5:	83 ec 08             	sub    $0x8,%esp
    va0 = (uint)PGROUNDDOWN(va);
801079f8:	89 55 0c             	mov    %edx,0xc(%ebp)
801079fb:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    pa0 = uva2ka(pgdir, (char*)va0);
80107a01:	57                   	push   %edi
80107a02:	ff 75 08             	pushl  0x8(%ebp)
80107a05:	e8 36 ff ff ff       	call   80107940 <uva2ka>
    if(pa0 == 0)
80107a0a:	83 c4 10             	add    $0x10,%esp
80107a0d:	85 c0                	test   %eax,%eax
80107a0f:	75 af                	jne    801079c0 <copyout+0x20>
  }
  return 0;
}
80107a11:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80107a14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107a19:	5b                   	pop    %ebx
80107a1a:	5e                   	pop    %esi
80107a1b:	5f                   	pop    %edi
80107a1c:	5d                   	pop    %ebp
80107a1d:	c3                   	ret    
80107a1e:	66 90                	xchg   %ax,%ax
80107a20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107a23:	31 c0                	xor    %eax,%eax
}
80107a25:	5b                   	pop    %ebx
80107a26:	5e                   	pop    %esi
80107a27:	5f                   	pop    %edi
80107a28:	5d                   	pop    %ebp
80107a29:	c3                   	ret    

select 
	origem.proder_codigo,
	origem.prod_nome,
	origem.demais_categorias,
	origem.marca_nome,
	sum(origem.qtde)::int as qtde,
	SUM(origem.total_venedido) as total_vendido,
	avg(origem.preco_medio) as preco_medio,
	origem.pedido_origem,
	origem.cat_nome as categoria_principal,
	origem.dataemissao,
	origem.custo_valor_atual,
	CASE WHEN origem.custo_valor_atual > 0 THEN (avg(origem.preco_medio) / origem.custo_valor_atual) ELSE 0 END as markup, origem.proder_nome
from
(select 
	marca_nome,
	pai.proder_codigo, 
	mz_produto.prod_nome,
	demais_categorias.categorias as demais_categorias,
	sum(nfitem_quantidade) as qtde, 
	sum(nfitem_valor_unitario) as total_venedido, 
	(sum(nfitem_valor_unitario) / sum(nfitem_quantidade)) as preco_medio,
	CASE WHEN ped_origem = 1 THEN 'Site'
            WHEN ped_origem = 2 AND lojmkt_nome = mktpl_nome then CONCAT_WS(' - ', 'Marketplace', lojmkt_nome)
            WHEN ped_origem = 2 THEN CONCAT_WS(' - ', 'Marketplace', lojmkt_nome, mktpl_nome)
            ELSE 'Manual'
			END AS pedido_origem,
		cat_nome,
		to_date(nf_data_emissao) as dataemissao,custo_valor_atual,mz_produto_derivacao.proder_nome
	from faturamento.ft_nota_fiscal     
	left join  faturamento.ft_pedido_nota_fiscal  on faturamento.ft_nota_fiscal .nf_id = faturamento.ft_pedido_nota_fiscal.nf_id 
	left join mz_pedido on faturamento.ft_pedido_nota_fiscal.ped_id = mz_pedido.ped_id 
	jOIN faturamento.ft_nota_fiscal_item ON ft_nota_fiscal_item.nf_id = ft_nota_fiscal.nf_id --AND ft_nota_fiscal_item.proder_id = mz_pedido_item.proder_id 
	join mz_produto_derivacao using (proder_id)
	join mz_produto_derivacao pai on pai.proder_id = mz_produto_derivacao.proder_id_pai
	join mz_produto on pai.prod_id = mz_produto.prod_id
	left join (select array_to_string(array_agg(cat_nome),' / ') as categorias,
                    a.prod_id,
                    a.proder_id 
                    from mz_produto_derivacao a  
                    join mz_categoria_produto b
                    on a.prod_id = b.prod_id 
                    join mz_categoria c
                    on c.cat_id = b.cat_id  
                    where proder_tipo_registro <> 1 
                    and catpro_principal = false
                    group by 2,3) as demais_categorias
    on demais_categorias.prod_id = mz_produto.prod_id
    and demais_categorias.proder_id = mz_produto_derivacao.proder_id  
	JOIN mz_categoria_produto catpro ON catpro.prod_id = mz_produto.prod_id AND catpro.catpro_principal IS TRUE
    JOIN mz_categoria ON mz_categoria.cat_id = catpro.cat_id
	join mz_marca on mz_produto.marca_id = mz_marca.marca_id 
	left join mz_estoque on mz_produto_derivacao.proder_id = mz_estoque.proder_id 
	LEFT JOIN mz_pedido_marketplace on mz_pedido.ped_id = mz_pedido_marketplace.ped_id 
    LEFT JOIN mz_loja_do_marketplace USING(lojmkt_id)
    LEFT JOIN mz_marketplace on mz_marketplace.mktpl_id = mz_loja_do_marketplace.mktpl_id   
	JOIN faturamento.ft_cfop_config ON faturamento.ft_nota_fiscal.percfop_id = ft_cfop_config.percfop_id
	LEFT JOIN estoque.es_custo_medio ON mz_produto_derivacao.proder_id = estoque.es_custo_medio.proder_id
    where percfop_tipo_operacao IN ( 1, 5 ) and nf_situacao = 3 and cast(nf_data_emissao as date) BETWEEN :inicio and :fim
    group by 1,2,3,4,mz_pedido.ped_origem,mz_loja_do_marketplace.lojmkt_nome,mz_marketplace.mktpl_nome,mz_categoria.cat_nome,ft_nota_fiscal.nf_data_emissao,custo_valor_atual,mz_produto_derivacao.proder_nome) origem
group by 1,2,3,4,8,9,10,11,13